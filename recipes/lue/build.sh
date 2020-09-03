#!/usr/bin/env bash
set -e


if [ $(uname) == Linux ]; then
  # Kindly guide to conda's OpenGL...
  PLATFORM_OPTIONS="-D OpenGL_GL_PREFERENCE=LEGACY \
  -D OPENGL_opengl_LIBRARY:PATH=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libGL.so \
  -D OPENGL_gl_LIBRARY:PATH=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/libGL.so "
else
  export MACOSX_DEPLOYMENT_TARGET=10.14
fi

# We need to create an out of source build
cd $SRC_DIR

mkdir -p build && cd build


cmake $SRC_DIR -G"Ninja" \
-D CMAKE_BUILD_TYPE=Release \
-D CMAKE_PREFIX_PATH:PATH="${PREFIX}" \
-D CMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
-D LUE_DATA_MODEL_WITH_PYTHON_API=ON \
-D LUE_DATA_MODEL_WITH_UTILITIES=ON \
-D LUE_BUILD_VIEW=ON \
-D Python3_FIND_STRATEGY="LOCATION" \
-D Python3_EXECUTABLE="${PYTHON}" \
-D PYTHON_EXECUTABLE="${PYTHON}" \
-D Python_ROOT_DIR="${PREFIX}/bin" \
-D Python3_ROOT_DIR="${PREFIX}/bin" \
$PLATFORM_OPTIONS

cmake --build . --target all

cmake --build . --target install
