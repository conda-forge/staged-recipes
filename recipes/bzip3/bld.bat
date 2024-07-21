cmake -S . -G Ninja -B build ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_VERBOSE_MAKEFILE=ON ^
    -Wno-dev ^
    -DBUILD_TESTING=OFF ^
    %CMAKE_ARGS%

cmake --build build
cmake --install build
