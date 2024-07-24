#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

if [[ ${target_platform} == "osx-arm64" ]]; then
    export CMAKE_ARGS="-DLLVM_TRIPLE='aarch64-apple-darwin' ${CMAKE_ARGS}"
fi

cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    -DLLDB_PACKAGE=${BUILD_PREFIX} \
    ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}

mkdir -p ${PREFIX}/bin
install -m 755 ./build/target/**/release/codelldb ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
install -m 644 ./build/adapter/libcodelldb${SHLIB_EXT} ${PREFIX}/lib
