@echo off
setlocal enabledelayedexpansion

cmake -B build -GNinja %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_CXX_SCAN_FOR_MODULES=OFF ^
    -DSLANG_INCLUDE_TOOLS=ON ^
    -DSLANG_INCLUDE_TESTS=OFF ^
    -DSLANG_INCLUDE_DOCS=OFF ^
    -DSLANG_INCLUDE_PYLIB=OFF ^
    -DSLANG_INCLUDE_INSTALL=ON ^
    -DSLANG_USE_MIMALLOC=OFF ^
    -DBUILD_SHARED_LIBS=ON ^
    .
if errorlevel 1 exit 1

cmake --build build -j%CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
