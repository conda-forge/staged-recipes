#!/bin/sh

rm -rf build
mkdir build
cd build

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS} -DYARPIDL_thrift_LOCATION=$BUILD_PREFIX/bin/yarpidl_thrift"
fi

cmake ${CMAKE_ARGS} -GNinja .. \
      -DBUILD_TESTING:BOOL=ON \
      -DTRINTRIN_COMPILE_PYTHON_BINDINGS:BOOL=OFF \
      ..

cmake --build . --config Release

if [[ ("${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "") ]]; then
  ctest --output-on-failure  -C Release
fi

cmake --build . --config Release --target install
