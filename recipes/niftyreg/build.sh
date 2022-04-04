set -euxo pipefail

rm -rf build || true
mkdir -p build/
cd build

# eigen3 is expected in this subdir; otherwise a bundled one is extracted
mkdir -p ./third-party
ln -s ${PREFIX}/include/eigen3 ./third-party/eigen3

cmake ${SRC_DIR} \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib

make
make install
