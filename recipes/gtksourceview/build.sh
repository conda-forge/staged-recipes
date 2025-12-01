#! /bin/bash

set -ex

# Setup pkg-config paths
# Prioritize PREFIX (host dependencies) so meson finds all glib components
export PKG_CONFIG=$BUILD_PREFIX/bin/pkg-config
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig:$BUILD_PREFIX/lib/pkgconfig
export PKG_CONFIG_PATH_FOR_BUILD=$BUILD_PREFIX/lib/pkgconfig
export XDG_DATA_DIRS=${XDG_DATA_DIRS}:$PREFIX/share

meson_config_args=(
    -Dintrospection=enabled
    -Dvapi=false
)

meson setup ${MESON_ARGS} \
    --prefix=$PREFIX \
    --default-library=shared \
    --wrap-mode=nofallback \
    "${meson_config_args[@]}" \
    builddir

ninja -v -C builddir -j ${CPU_COUNT}
ninja -C builddir install -j ${CPU_COUNT}
