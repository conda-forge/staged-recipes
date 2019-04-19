#!/bin/bash -e

function show_cmake_logs() {
  echo "Content of CMakeFiles/CMakeOutput.log:"
  cat CMakeFiles/CMakeOutput.log

  echo "Content of CMakeFiles/CMakeError.log:"
  cat CMakeFiles/CMakeError.log
}

# Workaround https://github.com/dealii/dealii/issues/7937
CXXFLAGS=$(echo "${CXXFLAGS}" | sed "s/-std=c++[0-9][0-9]//g")
CXXFLAGS=$(echo "${CXXFLAGS}" | sed "s/-stdlib=libc++//g")

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_PREFIX_PATH="${PREFIX}" \
      -DCMAKE_BUILD_TYPE=Release \
      -DDEAL_II_COMPONENT_EXAMPLES=OFF \
      -DDEAL_II_ALLOW_BUNDLED=OFF \
      -DBOOST_DIR="${PREFIX}" \
      -DTBB_DIR="${PREFIX}" \
      -DMUPARSER_DIR="${PREFIX}" \
      .. || (show_cmake_logs && exit 1)

make -j${CPU_COUNT}
make install
make test
