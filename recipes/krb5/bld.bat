:: First, make sure you have sed, gawk, cat, and cp
PATH C:\msys64\%MSYSTEM%\bin;C:\msys64\usr\bin;%PATH%

cd src

:: Create Makefile for Windows.
nmake -f Makefile.in prep-windows
if errorlevel 1 exit 1

:: Build the sources
nmake NODEBUG=1
if errorlevel 1 exit 1

:: Copy headers, libs, executables.
nmake install NODEBUG=1
if errorlevel 1 exit 1
