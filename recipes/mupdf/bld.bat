@echo off
setlocal EnableDelayedExpansion

:: build system uses non-standard env vars
set "XCFLAGS=%CFLAGS%"
set "XLIBS=%LIBS%"
set "USE_SYSTEM_LIBS=yes"
set "USE_SYSTEM_JPEGXR=yes"

:: build and install
make prefix="${PREFIX}" -j ${CPU_COUNT} all
if errorlevel 1 exit 1
:: no make check
make prefix="${PREFIX}" install
if errorlevel 1 exit 1
