mkdir build
cd build

cmake .. ${CMAKE_ARGS}
make install -j${CPU_COUNT}