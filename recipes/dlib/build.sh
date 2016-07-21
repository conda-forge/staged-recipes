#!/bin/bash

mkdir build
cd build

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  DYNAMIC_EXT="so"
fi
if [ "$(uname -s)" == "Darwin" ]; then
  DYNAMIC_EXT="dylib"
fi

if [ $PY3K -eq 1 ]; then
  export PY_STR="${PY_VER}m"
else
  export PY_STR="${PY_VER}"
fi

# Make the probably sensible assumption that a 64-bit
# machine supports SSE4 instructions - if this becomes
# a problem we should turn this off.
if [ $ARCH -eq 64 ]; then
  USE_SSE4=1
else
  USE_SSE4=0
fi

PYTHON_LIBRARY_PATH="$PREFIX/lib/libpython$PY_STR.$DYNAMIC_EXT"

cmake -LAH ../tools/python                              \
  -DCMAKE_PREFIX_PATH="$PREFIX"                         \
  -DCMAKE_BUILD_TYPE="Release"                          \
  -DBoost_USE_STATIC_LIBS=0                             \
  -DBoost_USE_STATIC_RUNTIME=0                          \
  -DBOOST_ROOT="$PREFIX"                                \
  -DBOOST_INCLUDEDIR="$PREFIX/include"                  \
  -DBOOST_LIBRARYDIR="$PREFIX/lib"                      \
  -DPYTHON_LIBRARY="$PYTHON_LIBRARY_PATH"               \
  -DPYTHON_INCLUDE_DIR="$PREFIX/include/python$PY_STR"  \
  -DPYTHON3=$PY3K                                       \
  -DDLIB_PNG_SUPPORT=1                                  \
  -DPNG_INCLUDE_DIR="$PREFIX/include"                   \
  -DPNG_PNG_INCLUDE_DIR="$PREFIX/include"               \
  -DPNG_LIBRARY="$PREFIX/lib/libpng.${DYNAMIC_EXT}"     \
  -DZLIB_INCLUDE_DIRS="$PREFIX/include"                 \
  -DZLIB_LIBRARIES="$PREFIX/lib/libz.${DYNAMIC_EXT}"    \
  -DDLIB_JPEG_SUPPORT=1                                 \
  -DJPEG_INCLUDE_DIR="$PREFIX/include"                  \
  -DJPEG_LIBRARY="$PREFIX/lib/libjpeg.${DYNAMIC_EXT}"   \
  -DDLIB_LINK_WITH_SQLITE3=1                            \
  -DDLIB_NO_GUI_SUPPORT=1                               \
  -DUSE_SSE2_INSTRUCTIONS=1                             \
  -DUSE_SSE4_INSTRUCTIONS=$USE_SSE4                     \
  -DUSE_AVX_INSTRUCTIONS=0                              \
  -DDLIB_USE_BLAS=1                                     \
  -DDLIB_USE_LAPACK=1                                   \
  -DDLIB_USE_CUDA=0                                     \
  -DDLIB_GIF_SUPPORT=0

make -j8
# Non-standard installation - copy manually
cp dlib.so $SP_DIR
