@echo off

set CMAKE_GENERATOR="Ninja"

cmake -G %CMAKE_GENERATOR% ^
   -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
   -DCMAKE_BUILD_TYPE:STRING=Release

if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
