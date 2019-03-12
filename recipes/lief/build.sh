#!/bin/bash

declare -a CMAKE_EXTRA_ARGS
if [[ ${target_platform} =~ linux-* ]]; then
  echo "Nothing special for linux"
elif [[ ${target_platform} == osx-64 ]]; then
  CMAKE_EXTRA_ARGS+=(-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT})
fi

mkdir build || true
cd build

if [[ ! -f Makefile ]]; then

  cmake .. -LAH                         \
    -DLIEF_VERSION_MAJOR=0              \
    -DLIEF_VERSION_MINOR=9              \
    -DLIEF_VERSION_PATCH=0              \
    -DCMAKE_BUILD_TYPE="Release"        \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"  \
    -DCMAKE_INSTALL_LIBDIR=lib          \
    -DCMAKE_SKIP_RPATH=ON               \
    -DCMAKE_AR="${AR}"                  \
    -DCMAKE_LINKER="${LD}"              \
    -DCMAKE_NM="${NM}"                  \
    -DCMAKE_OBJCOPY="${OBJCOPY}"        \
    -DCMAKE_OBJDUMP="${OBJDUMP}"        \
    -DCMAKE_RANLIB="${RANLIB}"          \
    -DCMAKE_STRIP="${STRIP}"            \
    -DBUILD_SHARED_LIBS=ON              \
    -DLIEF_PYTHON_API=OFF               \
    -DLIEF_INSTALL_PYTHON=OFF           \
    -DPYTHON_EXECUTABLE:FILEPATH=       \
    -DPYTHON_INCLUDE_DIR:PATH=          \
    -DPYTHON_LIBRARIES:PATH=            \
    -DPYTHON_LIBRARY:PATH=              \
    -DPYTHON_VERSION:STRING=            \
    -D_PYTHON_LIBRARY:FILEPATH=         \
    "${CMAKE_EXTRA_ARGS[@]}"

  if [[ ! $? ]]; then
    echo "configure failed with $?"
    exit 1
  fi
fi

make -j${CPU_COUNT} ${VERBOSE_CM}
