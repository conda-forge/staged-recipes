#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

meson ${MESON_ARGS} \
    --wrap-mode=nofallback \
    build \
    -Dgdk-pixbuf2=enabled \
    -Dlibcurl=enabled \
    -Dtests=enabled
meson compile -C build -v -j ${CPU_COUNT}
meson test -C build -j ${CPU_COUNT}
meson install -C build
