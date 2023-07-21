set -euxo pipefail

mkdir -p build
cd build

cmake ${CMAKE_ARGS} ${SRC_DIR} ${CMAKE_FLAGS} -DCMAKE_INSTALL_PREFIX=${PREFIX}

make
make install
