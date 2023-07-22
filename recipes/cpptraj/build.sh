set -euxo pipefail

mkdir -p build
cd build

cmake -DCOMPILER=MANUAL ${CMAKE_ARGS} ${SRC_DIR}

make
make install
