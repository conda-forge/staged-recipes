#!/usr/bin/env bash

set -eux # Abort on error.

mkdir build-lib
cd build-lib

if [[ "$OSTYPE" == "darwin"* ]]; then
	export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -Dfilepattern_SHARED_LIB=ON  ..

cmake --build . --target install --parallel