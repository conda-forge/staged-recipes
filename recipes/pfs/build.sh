set -ex
mkdir -p build
cd build
cmake ${CMAKE_ARGS}                \
    -DCMAKE_BUILD_TYPE=Release     \
    -Dpfs_BUILD_SHARED_LIBS=ON     \
    -Dpfs_BUILD_TESTS=OFF          \
    -Dpfs_BUILD_SAMPLES=OFF        \
    ..

make -j${CPU_COUNT}
make install
