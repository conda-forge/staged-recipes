#!/bin/bash -e

function show_cmake_logs() {
  echo "Content of CMakeFiles/CMakeOutput.log:"
  cat CMakeFiles/CMakeOutput.log

  echo "Content of CMakeFiles/CMakeError.log:"
  cat CMakeFiles/CMakeError.log
}

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DDEAL_II_ALLOW_BUNDLED=OFF \
      -DBOOST_DIR="${PREFIX}" \
      -DTBB_DIR="${PREFIX}" \
      -DMUPARSER_DIR="${PREFIX}" \
      .. || (show_cmake_logs && exit 1)

make -j${CPU_COUNT}
make install
make test
