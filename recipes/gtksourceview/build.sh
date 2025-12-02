#! /bin/bash

set -ex

export PKG_CONFIG=$BUILD_PREFIX/bin/pkg-config
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig:$BUILD_PREFIX/lib/pkgconfig
export PKG_CONFIG_PATH_FOR_BUILD=$BUILD_PREFIX/lib/pkgconfig
export XDG_DATA_DIRS=${XDG_DATA_DIRS}:$PREFIX/share

meson setup ${MESON_ARGS} \
    --prefix=$PREFIX \
    --default-library=shared \
    --wrap-mode=nofallback \
    -Dintrospection=enabled \
    -Dvapi=false \
    builddir

ninja -v -C builddir -j ${CPU_COUNT}
ninja -C builddir install -j ${CPU_COUNT}
