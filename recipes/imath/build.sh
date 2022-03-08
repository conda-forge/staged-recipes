#!/bin/bash

set -xeo pipefail

mkdir build
cd build

cmake_args=(
      ${CMAKE_ARGS}
      -DCMAKE_BUILD_TYPE=Release
      -DCMAKE_INSTALL_LIBDIR=lib
      -DCMAKE_INSTALL_PREFIX="$PREFIX"
      -DBUILD_SHARED_LIBS=ON
      -DIMATH_LIB_SUFFIX=
)

if [[ $(uname) == "Linux" ]]; then
      # This helps a test program link.
      cmake_args+=(
            -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS -Wl,--no-as-needed -lrt"
      )
fi

cmake "${cmake_args[@]}" ..
make -j${CPU_COUNT}
make install