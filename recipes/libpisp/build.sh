#!/bin/bash
# Exit immediately on error, print commands, and fail on pipe errors
set -exo pipefail

meson setup . ${MESON_ARGS} \
    -Dlogging=disabled
meson compile -C .
meson install -C .