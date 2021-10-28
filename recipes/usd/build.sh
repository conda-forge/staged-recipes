#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON \
      -DPXR_HEADLESS_TEST_MODE:BOOL=ON \
      -DPXR_BUILD_IMAGING:BOOL=OFF \
      -DPXR_BUILD_USD_IMAGING:BOOL=OFF \
      -DPXR_ENABLE_PYTHON_SUPPORT:BOOL=OFF \
      -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY:BOOL=ON

cmake --build . --config Release 
cmake --build . --config Release --target install
ctest --output-on-failure -C Release
