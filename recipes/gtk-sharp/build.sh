#!/usr/bin/env bash

set -euxo pipefail

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${BUILD_PREFIX}/lib/pkgconfig"

LIBTOOL=$(which libtool)

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