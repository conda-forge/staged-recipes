set -euxo pipefail

rm -rf build || true
mkdir -p build/
cd build

# create this directory so CMake doesn't use the bundled eigen
mkdir -p ${SRC_DIR}/third-party/eigen3

cmake ${SRC_DIR} \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib

make
make install
