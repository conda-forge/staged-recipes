mkdir build
cd build

cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DPAGMO_WITH_EIGEN3=yes ^
    -DPAGMO_WITH_NLOPT=yes
    ..

cmake --build . --config Release

ctest

cmake --build . --config Release --target install
