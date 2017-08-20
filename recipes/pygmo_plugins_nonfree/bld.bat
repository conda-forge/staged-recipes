mkdir build
cd build

cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DPAGMO_PLUGINS_NONFREE_BUILD_PYTHON=yes ^
    -DPAGMO_PLUGINS_NONFREE_BUILD_TESTS=no ^
    ..

cmake --build . --config Release

cmake --build . --config Release --target install

