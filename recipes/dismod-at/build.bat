:: echo
echo off

::
mkdir %PREFIX%\bin
copy %RECIPE_DIR%\dismodat.py.bat %PREFIX%\Library\bin\dismodat.py.bat

:: build
mkdir build
cd build

:: PKG_CONFIG_PATH
set PKG_CONFIG_PATH=^
%BUILD_PREIX%\Library\lib\pkgconfig;^
%BUILD_PREIX%\Library\share\pkgconfig;
echo PKG_CONFIG_PATH=%PKG_CONFIG_PATH%

:: cmake
cmake -S %SRC_DIR% -B . ^
   -G "Ninja" ^
   -D CMAKE_BUILD_TYPE=Release ^
   -D extra_cxx_flags="/std:c++17" ^
   -D dismod_at_prefix="%PREFIX%\Library" ^
   -D cmake_libdir=lib ^
   -D python3_executable="python3" 
if errorlevel 1 exit 1

:: build
:: dismod_at C++ executable
ninja -j%CPU_COUNT% dismod_at
if errorlevel 1 exit 1

:: build
::  dismod_at unit tests (developer tests) can be built in parallel
ninja -j%CPU_COUNT% example_devel test_devel
if errorlevel 1 exit 1

:: check
:: This target does not support parallel execution because many of the 
:: user tests use the same file name.
ninja -j1 check
if errorlevel 1 exit 1

:: C++ install
ninja -j%CPU_COUNT% install
if errorlevel 1 exit 1

:: python install
%PYTHON% -m pip install $SRC_DIR/python  -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
%PYTHON% -m pip show dismod_at
if errorlevel 1 exit 1

echo 'build.bat: OK'
