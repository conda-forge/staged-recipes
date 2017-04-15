mkdir build
cd build

cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DPAGMO_WITH_EIGEN3=yes ^
    -DPAGMO_WITH_NLOPT=yes ^
    -DPAGMO_INSTALL_HEADERS=no ^
    -DPAGMO_BUILD_PYGMO=yes ^
    ..

cmake --build . --config Release

cmake --build . --config Release --target install

