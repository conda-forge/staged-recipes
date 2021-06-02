#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_TESTING=ON \
      -DUNITTESTS=ON \
      ..

cmake --build . --config Release --parallel ${CPU_COUNT}
cmake --build . --config Release --parallel ${CPU_COUNT} --target install
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
ctest --output-on-failure -C Release
fi
