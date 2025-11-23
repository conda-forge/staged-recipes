@echo off

setlocal EnableDelayedExpansion

if not exist build mkdir build
cd build

cmake -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_INSTALL_PREFIX=%LIRARY_PREFIX% ^
    ..

cmake --build . --config Release
cmake --install . --config Release

cd ..
