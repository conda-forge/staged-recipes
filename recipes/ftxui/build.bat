@echo off
REM Windows build script for ftxui
setlocal enableextensions enabledelayedexpansion

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DBUILD_SHARED_LIBS=ON
cmake --build build --parallel %CPU_COUNT%
cmake --install build --prefix %LIBRARY_PREFIX%
