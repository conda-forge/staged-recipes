set -ex

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
    -G "Ninja" \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    ..

ninja install
