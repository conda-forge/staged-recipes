#!/bin/bash
# Exit immediately on error, print commands, and fail on pipe errors
set -exo pipefail

mkdir -p build

meson setup build ${MESON_ARGS} \
    -Dlogging=disabled \
    -Dc_args=-Wno-unused-parameter \
    -Dcpp_args=-Wno-unused-parameter
meson compile -C build
meson install -C build