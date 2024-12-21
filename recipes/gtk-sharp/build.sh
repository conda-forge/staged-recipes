#!/usr/bin/env bash

set -euxo pipefail

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${BUILD_PREFIX}/lib/pkgconfig"

LIBTOOL=$(which libtool)

if [[ ${target_platform} == win-* ]]; then
    CC=x86_64-w64-mingw32-gcc
    AR=x86_64-w64-mingw32-ar
    RANLIB=x86_64-w64-mingw32-ranlib
    STRIP=x86_64-w64-mingw32-strip
    LD=x86_64-w64-mingw32-ld
fi
# Split off last part of the version string
_pkg_version=$(echo "${PKG_VERSION}" | sed -e 's/\.[^.]\+$//')
./bootstrap-${_pkg_version} --prefix=$(pkg-config --variable=prefix mono)
# This should fine the PREFIX mono (check for cross-compilation)
./configure \
  --prefix=$(pkg-config --variable=prefix mono) \
  --disable-static
make
make install

# Rename the .so on osx
if [[ ${target_platform} == osx-* ]]; then
    cd $(pkg-config --variable=prefix mono)/lib
    for f in *.so; do
        if [ -f "$f" ]; then
            mv "$f" "${f%.so}.dylib"
        fi
    done
fi