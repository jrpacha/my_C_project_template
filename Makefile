# This Makefile will help to build over 90% of your projects in C/C+ and
# fortran 77
#
# Sources. See,
# http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/
# http://nuclear.mutantstargoat.com/articles/make/
#Here we use much of the code that's in these webs!
#
# Use:
# Create a folder to hold your project, for example
# 	~$ mkdir my_project
# and copy this makefile there
# 	~$ cp Makefile ~/my_project/
# In addition, create two subfolders, include 
# 	~$ mkdir ~/my_project/include
# to place your include (.h, .hh) files, and src
# 	~$ mkdir ~/my_project/src
# to place your source (.c, .cc, .cpp) files.
# Then, to build you project just cd to the project folder, i.e.,
# 	~$ cd ~/my_project
# and run make
# 	~/my_project $ make 
# Other actions
# -- To delete the .o (object) and .d (dependence) files
# 	~/my_project $ make clean
# -- To remove .o .d and exec files
# 	~/my_project mrproper

PROG=$(notdir $(CURDIR))#name of the project
SRCDIR=       src
HDIR =        include
OBJDIR=       .o
DEPDIR=       .d

ifdef OS
    $(shell mkdir $(OBJDIR) 2>NUL:)
    $(shell mkdir $(DEPDIR) 2>NUL:)
    MV = move
    POSTCOMPILE = $(MV) $(DEPDIR)\$*.Td $(DEPDIR)\$*.d 2>NUL
    RMFILES = del /Q /F $(OBJDIR)\*.o $(DEPDIR)\*.d 2>NUL
    RMDIR = rd $(OBJDIR) $(DEPDIR) 2>NUL
    EXE=$(PROG:=.exe)
    RUN=$(EXE)
    RMEXE= del /Q /F $(EXE) 2>NUL
    USE=Use:
    USE.HELP='make help', to see other options.
    USE.BUILD='make $(PROG)', to build the executable, $(PROG).
    USE.CLEAN='make clean', to delete the object and dep files.
    USE.MRPROPER='make mrproper', to delete the executable as well.
    ECHO=@echo.
else 
    ifeq ($(shell uname), Linux)
        USE="Use:"
        USE.HELP="      'make help', to see other options."
        USE.BUILD="     'make ${PROG}', to build the executable, $(PROG)."
        USE.CLEAN="     'make clean', to delete the object and dep files."
        USE.MRPROPER="     'make mrproper', to delete the executable as well."
        $(shell mkdir -p $(OBJDIR) >/dev/null)
        $(shell mkdir -p $(DEPDIR) >/dev/null)
        MV = mv -f
        POSTCOMPILE = $(MV) $(DEPDIR)/$*.Td $(DEPDIR)/$*.d
        RMFILES = $(RM) $(OBJDIR)/*.o $(DEPDIR)/*.d
        RMDIR = rmdir $(OBJDIR) $(DEPDIR)
        EXE= $(PROG)
        RUN= ./$(EXE)
        RMEXE = rm -f $(EXE)
        ECHO=@echo
    endif
endif

SRCS_ALL=$(wildcard $(SRCDIR)/*.c)
SRCS_ALL+=$(wildcard $(SRCDIR)/*.cc)
SRCS_ALL+=$(wildcard $(SRCDIR)/*.f)

SRCS=$(filter-out %_flymake.c, $(notdir $(basename $(SRCS_ALL))))
SRCS+=$(filter-out %_flymake.cc, $(notdir $(basename $(SRCS_ALL))))
SRCS+=$(filter-out %_flymake.f, $(notdir $(basename $(SRCS_ALL))))

OBJS=$(patsubst %,$(OBJDIR)/%.o,$(SRCS))
DEPS=$(patsubst %,$(DEPDIR)/%.d,$(SRCS))

CC=            gcc
CCFLAGS=      -g -O0 #-fPIC
CCLIBS=	      #-lm

CXX=           g++
CXXFLAGS=     -g -O0
CXXLIBS=      #-lm

FC=            gfortran
FFLAGS=       -g -O3 -std=legacy #-Wall -Wextra -Wconversion
FFLIBS=

CPPFLAGS+=    -cpp -MMD -MP -MF $(DEPDIR)/$*.Td
LDFLAGS=

# Note: -std=legacy.  We use std=legacy to compile fortran 77

PROG_RELEASE=$(PROG)_release

$(PROG_RELEASE): $(EXE)

$(EXE): $(OBJS)
	$(CXX) -o$@ $^ $(LDFLAGS) $(CXXLIBS) $(CCLIBS) $(FFLIBS)
	$(ECHO)
	$(ECHO) $(USE)
	$(ECHO)      $(USE.HELP)
	$(ECHO)

run: $(EXE)
	$(RUN)

help:
	$(ECHO)
	$(ECHO) $(USE)
	$(ECHO)      $(USE.BUILD)
	$(ECHO)      $(USE.CLEAN)
	$(ECHO)      $(USE.MRPROPER)
	$(ECHO)

filter:
	$(ECHO) $(SRCS_ALL)
	$(ECHO) "== filter example =="
	$(ECHO) "filter: " $(filter %_flymake.cc, $(SRCS_ALL))
	$(ECHO) "filter-out: $(filter-out %_flymake.c, $(SRCS_ALL))"
	$(ECHO)

clean:
	$(RMFILES)
	$(RMDIR)

mrproper: clean
	$(RMEXE)

$(OBJDIR)/%.o: $(SRCDIR)/%.c $(DEPDIR)/%.d
	$(CC) $(CCFLAGS) $(CPPFLAGS) -I$(HDIR) -c $< -o$@
	$(POSTCOMPILE)

$(OBJDIR)/%.o: $(SRCDIR)/%.cc $(DEPDIR)/%.d
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -I$(HDIR) -c $< -o$@
	$(POSTCOMPILE)

$(OBJDIR)/%.o: $(SRCDIR)/%.f $(DEPDIR)/%.d
	$(FC) $(FFLAGS) $(CPPFLAGS) -I$(HDIR) -c $< -o$@
	$(POSTCOMPILE)

$(DEPDIR)/%.d:;
.PRECIOUS: $(DEPDIR)

-include $(DEPS)

.PHONY: clean mrproper $(PROG_RELEASE) run