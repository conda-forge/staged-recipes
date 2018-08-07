@echo off

rem mkdir build
rem cd build

set CMAKE_GENERATOR="Ninja"
rem set CMAKE_GENERATOR="NMake Makefiles"
rem set CMAKE_GENERATOR="Visual Studio 14 2015 Win64"

cmake -G %CMAKE_GENERATOR% ^
   -Wno-dev ^
   -DCMAKE_BUILD_TYPE=Release ^
   -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
   -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%"

rem nmake
cmake --build . --config Release --target ALL_BUILD 1>output.txt 2>&1
if errorlevel 1 exit 1

rem nmake install
cmake --build . --config Release --target INSTALL
if errorlevel 1 exit 1
