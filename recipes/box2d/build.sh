#!/usr/bin/env bash

set -ex # Abort on error.

rm -rf build
mkdir build
cd build

# From original box2d bash script:
# I haven't been able to get Wayland working on WSL but X11 works.
# https://www.glfw.org/docs/latest/compile.html
cmake \
      ${CMAKE_ARGS} \
      -GNinja \
      -DBUILD_SHARED_LIBS=ON \
      -DBOX2D_BUILD_DOCS=OFF \
      -DBOX2D_COMPILE_WARNING_AS_ERROR=OFF \
      -DBOX2D_SAMPLES=OFF \
      -DGLFW_BUILD_WAYLAND=OFF \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ${SRC_DIR}
cmake --build . -j "${CPU_COUNT}"
cmake --build . --target install
