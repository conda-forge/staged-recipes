#!/bin/sh
set -ex

CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

if test "$CONDA_BUILD_CROSS_COMPILATION" = "1"
then
  CMAKE_ARGS="${CMAKE_ARGS} -DQT_HOST_PATH=${BUILD_PREFIX}"
fi

if [[ $(uname) == "Linux" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DFEATURE_egl=ON -DFEATURE_eglfs=ON -DFEATURE_xcb=ON -DFEATURE_xcb_xlib=ON -DFEATURE_xkbcommon=ON"
  CMAKE_ARGS="${CMAKE_ARGS} -DFEATURE_vulkan=ON"
fi

mkdir build
cd build

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_FIND_FRAMEWORK=LAST \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
  -DCMAKE_MESSAGE_LOG_LEVEL=STATUS \
  -DFEATURE_linux_v4l=OFF \
  -DFEATURE_quick3d_assimp=OFF \
  ..

cmake --build . --target install