mkdir build
cd build

cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_SPICE=yes ^
    -DBUILD_MAIN=no ^
    -DBUILD_PYKEP=yes ^
    -DBUILD_TESTS=yes ^
    ..

cmake --build . --config Release

ctest

cmake --build . --config Release --target install