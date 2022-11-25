#!/bin/sh

mkdir build
cd build

cmake -G "NMake Makefiles" ^
	  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      %SRC_DIR%

if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
