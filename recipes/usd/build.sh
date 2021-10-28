#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=ON \
      -DPXR_HEADLESS_TEST_MODE=ON \
      -DPXR_BUILD_IMAGING=OFF \
      -DPXR_BUILD_USD_IMAGING=OFF \
      -DPXR_ENABLE_PYTHON_SUPPORT=OFF 

cmake --build . --config Release 
cmake --build . --config Release --target install
ctest --output-on-failure -C Release
