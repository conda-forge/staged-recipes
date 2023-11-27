@echo on
setlocal enabledelayedexpansion

mkdir builddir

:: check if clang-cl is on path as required
clang-cl.exe --version
if %ERRORLEVEL% neq 0 exit 1

:: set compilers to clang-cl
set "CC=clang-cl"
set "CXX=clang-cl"

:: install the package by pip
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation ^
    -Cbuilddir=builddir
if %ERRORLEVEL% neq 0 (type builddir\meson-logs\meson-log.txt && exit 1)
