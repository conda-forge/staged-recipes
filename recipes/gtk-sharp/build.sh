#!/usr/bin/env bash

set -euxo pipefail

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${BUILD_PREFIX}/lib/pkgconfig"

if [[ ${target_platform} == osx-* ]]; then
  # Find libtool on OSX conda environment
  echo $(which libtool)
  LIBTOOL=$(which libtool)
  ${LIBTOOL} --version
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
