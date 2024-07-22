#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

meson ${MESON_ARGS} --wrap-mode=nofallback build
meson compile -C build -v
meson install -C build
