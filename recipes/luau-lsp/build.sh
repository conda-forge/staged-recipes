#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*osx.* ]]; then
    if [[ ${target_platform} == "osx-64" ]]; then
        arch="x86_64"
    else
        arch="arm64"
    fi
    cmake -S . -B build ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES="${arch}"
else
    cmake -S . -B build ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="${CXXFLAGS} -Wno-maybe-uninitialized"
fi
cmake --build build --target Luau.LanguageServer.CLI --config Release -j${CPU_COUNT}

mkdir -p ${PREFIX}/bin
install -m 755 build/${PKG_NAME} ${PREFIX}/bin
