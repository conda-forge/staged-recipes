#!/bin/sh

mkdir build
cd build

# -fvisibility-inlines-hidden results in linking errors like:
# testVtCpp.cpp:(.text.startup.main+0x2fa): undefined reference to pxrInternal_v0_25_2__pxrReserved__::VtArray<int>::_DecRef()'
# This is a temporary workaround until https://github.com/PixarAnimationStudios/OpenUSD/pull/3452 is merged upstream,
# that should solve this issue in a clean way
export CFLAGS="$(echo $CFLAGS | sed 's/-fvisibility-inlines-hidden//g')"
export CXXFLAGS="$(echo $CXXFLAGS | sed 's/-fvisibility-inlines-hidden//g')"

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON \
      -DPXR_HEADLESS_TEST_MODE:BOOL=ON \
      -DPXR_BUILD_IMAGING:BOOL=ON \
      -DPXR_BUILD_USD_IMAGING:BOOL=ON \
      -DPXR_ENABLE_PYTHON_SUPPORT:BOOL=ON \
      -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY:BOOL=ON

cmake --build . --config Release 
cmake --build . --config Release --target install
ctest --output-on-failure -C Release
