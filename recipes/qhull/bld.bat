@echo off

rem mkdir build
rem cd build

set CMAKE_GENERATOR="Ninja"
rem set CMAKE_GENERATOR="NMake Makefiles"
rem set CMAKE_GENERATOR="Visual Studio 14 2015 Win64"

cmake -G %CMAKE_GENERATOR% ^
   -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
   -DCMAKE_BUILD_TYPE:STRING=Release

rem nmake
rem cmake --build . --config Release --target ALL_BUILD 1>output.txt 2>&1
if errorlevel 1 exit 1

rem nmake install
ninja install
rem cmake --build . --config Release --target INSTALL
if errorlevel 1 exit 1
