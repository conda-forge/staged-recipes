#!/usr/bin/env bash

set -eux # Abort on error.

mkdir build
cd build

if [[ "$target_platform" == osx-* ]]; then
	export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake $CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release -Dfilepattern_SHARED_LIB=ON  ../src/filepattern/cpp/

cmake --build . --target install --parallel -j${CPU_COUNT}