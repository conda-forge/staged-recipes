mkdir build
cd build

cmake ^
    -G %CMAKE_GENERATOR% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_BENCHMARKS=no ^
    -DINTEGER_CLASS=gmp ^
    -DWITH_SYMENGINE_THREAD_SAFE=yes ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_FOR_DISTRIBUTION=yes ^
    -DBUILD_SHARED_LIBS=yes ^
    ..

cmake --build . --config Release
cmake --build . --config Release --target install

ctest
