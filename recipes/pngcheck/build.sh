set -ex

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    ..

ninja install
