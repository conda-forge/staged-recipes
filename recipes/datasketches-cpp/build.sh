cd build
cmake -G Ninja ${CMAKE_ARGS} ..
ninja install -j${CPU_COUNT}
