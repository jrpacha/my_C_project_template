# Template folder for FORTRAN/C/C++ projects

my_project: Template for my C/C++ projects:

-- Put your source files in **src** directory
-- Put yout include file in **include** directory

To build the project:

~$ make -f my_project.mak my_project_release

To clean the project

~$ make -f my_project.mak clean

To clean the project completely

~$ make -f my_project.mak mrproper
