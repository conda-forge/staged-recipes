cd deps/clog

mkdir build
cd build
cmake ${CMAKE_ARGS}                \
    -DCMAKE_BUILD_TYPE=Release     \
    -DCLOG_RUNTIME_TYPE=shared     \
    -DCLOG_BUILD_TESTS=OFF         \
    ..
make -j${CPU_COUNT}
make install
