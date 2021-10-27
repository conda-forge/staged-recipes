set -euxo pipefail
mkdir build
cd build
cmake ${SRC_DIR} ${CMAKE_ARGS}
make install