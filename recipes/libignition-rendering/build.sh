#!/bin/sh

mkdir build
cd build

cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
      -DCMAKE_C_FLAGS=-DGLX_GLXEXT_LEGACY \
      -DCMAKE_CXX_FLAGS=-DGLX_GLXEXT_LEGACY

cmake --build . --config Release
cmake --build . --config Release --target install
ctest -C Release -E "INTEGRATION|PERFORMANCE|REGRESSION|UNIT_RenderingIface_TEST|check_UNIT_RenderingIface_TEST"
