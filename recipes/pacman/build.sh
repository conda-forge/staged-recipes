set -ex

cmake  ${CMAKE_ARGS} -S ${SRC_DIR} -B build \
-G Ninja \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=$PREFIX \
-DPACMAN_PYTHON_DIR=$SP_DIR \
-DBUILD_TESTS=OFF \
-DBUILD_FORTRAN_INTERFACE=OFF

cmake --build build

cmake --install build