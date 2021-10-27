set -euxo pipefail
mkdir build
cd build
cmake ${SRC_DIR} ${CMAKE_ARGS} -DBUILD_PYTHON_WRAPPER=ON
make
make install