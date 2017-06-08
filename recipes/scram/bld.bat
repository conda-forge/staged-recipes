mkdir build
cd build

cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_GUI=OFF ^
    -DBUILD_TESTS=OFF ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DINSTALL_LIBS=OFF ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..

cmake --build . --config Release

cmake --build . --config Release --target install
