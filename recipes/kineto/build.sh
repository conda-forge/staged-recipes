cd libkineto

mkdir build
cd build
cmake ${CMAKE_ARGS}                \
    -DCMAKE_BUILD_TYPE=Release     \
    -DKINETO_BUILD_TESTS=0         \
    -DKINETO_LIBRARY_TYPE=shared   \
    -DLIBKINETO_NOCUPTI=1          \
    ..

make -j${CPU_COUNT}
make install

