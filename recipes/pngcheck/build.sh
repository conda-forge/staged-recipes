set -ex

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    ..

make -j${CPU_COUNT} VERBOSE=1
make install
