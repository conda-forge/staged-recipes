#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Remove some tests that don't work in CI
rm test/rtpw_test.sh
rm test/rtpw_test_gcm.sh

meson ${MESON_ARGS} \
    --wrap-mode=nofallback \
    build \
    -Dtests=enabled
meson compile -C build -v
meson test -C build
meson install -C build
