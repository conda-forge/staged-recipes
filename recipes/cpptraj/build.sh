set -euxo pipefail

mkdir -p build
cd build

cmake ${CMAKE_ARGS} ${SRC_DIR}

make
make install
