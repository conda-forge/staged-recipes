#! /bin/bash

set -ex

meson setup ${MESON_ARGS} \
    --prefix=$PREFIX \
    --default-library=shared \
    --wrap-mode=nofallback \
    -Dintrospection=enabled \
    -Ddocumentation=false \
    -Dvapi=false \
    builddir

ninja -v -C builddir -j ${CPU_COUNT}
ninja -C builddir install -j ${CPU_COUNT}
