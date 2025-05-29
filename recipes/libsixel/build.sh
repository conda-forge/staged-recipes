#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

meson ${MESON_ARGS} \
    --wrap-mode=nofallback \
    build \
    -Dgdk-pixbuf2=enabled \
    -Dtests=enabled
meson compile -C build -v
meson test -C build
meson install -C build
