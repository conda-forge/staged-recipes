mkdir build
cd build

cmake ^
    -DBUILD_TESTS=no ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    ..

cmake --build . --target install --config Release
