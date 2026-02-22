@echo off
setlocal enabledelayedexpansion

mkdir build && cd build

cmake %CMAKE_ARGS% ^
    -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DSLANG_INCLUDE_TOOLS=ON ^
    -DSLANG_INCLUDE_TESTS=OFF ^
    -DSLANG_INCLUDE_DOCS=OFF ^
    -DSLANG_INCLUDE_PYLIB=OFF ^
    -DSLANG_INCLUDE_INSTALL=ON ^
    -DSLANG_USE_MIMALLOC=OFF ^
    -DBUILD_SHARED_LIBS=ON ^
    ..
if errorlevel 1 exit 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
