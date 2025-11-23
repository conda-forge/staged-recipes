@echo off

setlocal EnableDelayedExpansion

if not exist build mkdir build
cd build

cmake .. ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
    -G "NMake Makefiles"

cmake --build . --config Release
cmake --install . --config Release

cd ..
