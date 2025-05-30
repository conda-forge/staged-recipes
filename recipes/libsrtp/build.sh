#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

meson ${MESON_ARGS} \
    --wrap-mode=nofallback \
    build \
    -Dtests=enabled
meson compile -C build -v
meson test -C build
meson install -C build
