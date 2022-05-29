mkdir build
cd build
cmake ${CMAKE_ARGS}                \
    -DBUILD_SHARED_LIBS=1          \
    ..
make -j${CPU_COUNT}
make install
