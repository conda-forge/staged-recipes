set -euxo pipefail

rm -rf build || true
mkdir -p build/
cd build

cmake ${SRC_DIR} ${CMAKE_ARGS}

make
make install
