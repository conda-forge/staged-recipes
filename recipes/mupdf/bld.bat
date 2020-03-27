@echo off
setlocal EnableDelayedExpansion

:: build system uses non-standard env vars
set "XCFLAGS=%CFLAGS% -I %LIBRARY_PREFIX%\\include"
set "XLIBS=%LIBS%"
set "USE_SYSTEM_LIBS=yes"
set "USE_SYSTEM_JPEGXR=yes"

:: diagnostics
dir %LIBRARY_PREFIX%\\include

:: build and install
make "prefix=%LIBRARY_PREFIX%" -j %CPU_COUNT% all
if errorlevel 1 exit 1
:: no make check
make "prefix=%LIBRARY_PREFIX%" install
if errorlevel 1 exit 1
