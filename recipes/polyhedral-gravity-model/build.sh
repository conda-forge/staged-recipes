mkdir build
cd build

cmake ^
    -G "Ninja"
    -DCMAKE_BUILD_TYPE=Release
    ..

cmake --build . --config Release

ctest

cmake --build . --config Release --target install
