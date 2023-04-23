#!/usr/bin/env bash

set -eux # Abort on error.

mkdir build
cd build

if [[ "$OSTYPE" == "darwin"* ]]; then
	export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DFMJPEG2K=${PREFIX} ..

cmake --build . --target install --parallel
