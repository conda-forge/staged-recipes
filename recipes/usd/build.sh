#!/bin/sh

mkdir build
cd build

# -fvisibility-inlines-hidden results in linking errors like:
# testVtCpp.cpp:(.text.startup.main+0x2fa): undefined reference to pxrInternal_v0_25_2__pxrReserved__::VtArray<int>::_DecRef()'
# This is a temporary workaround until https://github.com/PixarAnimationStudios/OpenUSD/pull/3452 is merged upstream,
# that should solve this issue in a clean way
export CFLAGS="$(echo $CFLAGS | sed 's/-fvisibility-inlines-hidden//g')"
export CXXFLAGS="$(echo $CXXFLAGS | sed 's/-fvisibility-inlines-hidden//g')"

# From https://conda-forge.org/docs/maintainer/knowledge_base/#finding-numpy-in-cross-compiled-python-packages-using-cmake
Python_INCLUDE_DIR="$(python -c 'import sysconfig; print(sysconfig.get_path("include"))')"
CMAKE_ARGS="${CMAKE_ARGS} -DPython_EXECUTABLE:PATH=${PYTHON}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython_INCLUDE_DIR:PATH=${Python_INCLUDE_DIR}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_EXECUTABLE:PATH=${PYTHON}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_INCLUDE_DIR:PATH=${Python_INCLUDE_DIR}"

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
