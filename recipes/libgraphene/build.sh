#!/bin/bash

set -xeo pipefail

meson_options=(
    --buildtype=release
    --backend=ninja
    -Dgtk_doc=false
    -Dgobject_types=true
    -Dinstalled_tests=false
    -Dlibdir=lib
    -Dintrospection=enabled
    --wrap-mode=nofallback
)
mkdir forgebuild
cd forgebuild

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$BUILD_PREFIX/lib/pkgconfig"

meson "${meson_options[@]}" --prefix=$PREFIX ..
ninja -j$CPU_COUNT -v
ninja install

