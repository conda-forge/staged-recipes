gcc --version > version_output.log
set /p output= <version_output.log
if not "%output%" == "gcc (x86_64-posix-seh-rev0, Built by MinGW-W64 project) %PKG_VERSION%" exit /b 1

:: Compile and run a simple hello
echo #include ^<stdio.h^> >hello.c
echo int main() { printf("Hello, World!"); return 0; } >>hello.c

gcc -Wall hello.c -o hello.exe

hello.exe > hello_output.log
set /p output= <hello_output.log
if not "%output%" == "Hello, World!" exit /b 1

gdb --version