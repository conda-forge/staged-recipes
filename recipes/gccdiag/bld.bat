cmake -S . -G Ninja -B build ^
    -DCMAKE_CXX_FLAGS="-D_LIBCPP_DISABLE_AVAILABILITY" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_VERBOSE_MAKEFILE=ON ^
    -Wno-dev ^
    -DBUILD_TESTING=OFF ^
    %CMAKE_ARGS%

cmake --build build -j%CPU_COUNT%
cmake --install build
