#! /bin/sh

cmake ${CMAKE_ARGS} "${SRC_DIR}"

cmake --build .
ctest
cmake --install .
