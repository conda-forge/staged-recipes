#!/usr/bin/env bash

set -euxo pipefail

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${BUILD_PREFIX}/lib/pkgconfig"

LIBTOOL=$(which libtool)

host_conda_libs="${PREFIX}/Library/lib"
build_conda_libs="${BUILD_PREFIX}/Library/lib"
paths=(
    "${host_conda_libs}/pkgconfig"
    "${build_conda_libs}/pkgconfig"
)

# Loop through the paths and update PKG_CONFIG_PATH
for path in "${paths[@]}"; do
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}${PKG_CONFIG_PATH:+:}${path}"
done
PKG_CONFIG=$(which pkg-config.exe | sed -E 's|^/(\w)|\1:|')
PKG_CONFIG_PATH=$(echo "$PKG_CONFIG_PATH" | sed -E 's|^(\w):|/\1|' | sed -E 's|:(\w):|:/\1|g')

export PKG_CONFIG
export PKG_CONFIG_PATH
export PKG_CONFIG_LIBDIR="${PKG_CONFIG_PATH}"
export PATH="${BUILD_PREFIX}/Library/bin:${PREFIX}/Library/bin${PATH:+:${PATH:-}}"
export CC=x86_64-w64-mingw32-gcc
export AR=x86_64-w64-mingw32-ar
export RANLIB=x86_64-w64-mingw32-ranlib
export STRIP=x86_64-w64-mingw32-strip
export LD=x86_64-w64-mingw32-ld
_prefix=${PREFIX}
# Split off last part of the version string
_pkg_version=$(echo "${PKG_VERSION}" | sed -e 's/\.[^.]\+$//')

# Bootstrap with dotnet configuration
./bootstrap-${_pkg_version} --prefix=${_prefix}
# autoreconf -vif
autoupdate
sed -E 's/(ac_cv_path_PKG_CONFIG=)/\necho \$PKG_CONFIG"\n\1/' configure
# Configure specifically for dotnet on Windows
PKG_CONFIG="${PKG_CONFIG}" ./configure \
    --prefix=${_prefix} \
    --disable-static \
    --enable-dotnet \
    --disable-mono

make
make install
