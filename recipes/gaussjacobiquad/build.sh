#!/usr/bin/env bash
set -euxo pipefail

# MESON_ARGS already sets --prefix and often --libdir; avoid duplicate flags.
meson setup build ${MESON_ARGS} -Dwarning_level=1
meson compile -C build -j "${CPU_COUNT:-2}"
meson install -C build

# Upstream library target is misspelled GaussJacobiQaud; install still places bin/gjp_quad.
test -x "${PREFIX}/bin/gjp_quad"
