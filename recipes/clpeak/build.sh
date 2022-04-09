mkdir build
cd build

cmake ${CMAKE_ARGS} -G Ninja ..
ninja -j${CPU_COUNT}
ninja -j${CPU_COUNT} install
ctest
