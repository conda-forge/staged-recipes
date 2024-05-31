#!/bin/bash
set -e -x

mkdir build
pushd build

export XDG_DATA_DIRS=${XDG_DATA_DIRS}:$PREFIX/share:$BUILD_PREFIX/share
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig:$BUILD_PREFIX/lib/pkgconfig
EXTRA_FLAGS=""
if [[ $CONDA_BUILD_CROSS_COMPILATION == "1" ]]; then
  EXTRA_FLAGS="--cross-file $BUILD_PREFIX/meson_cross_file.txt"
fi

export PKG_CONFIG=$(which pkg-config)

meson setup --buildtype=release --prefix=${PREFIX} --libdir=${PREFIX}/lib ${EXTRA_FLAGS} ..
ninja -j${CPU_COUNT}
ninja install

rm -rf ${PREFIX}/share/man

# Remove any new Libtool files we may have installed. It is intended that
# conda-build will eventually do this automatically.
find ${PREFIX}/. -name '*.la' -delete
