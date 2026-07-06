#!/usr/bin/env bash
set -euxo pipefail

meson setup build ${MESON_ARGS} \
  --prefix="${PREFIX}" \
  --libdir=lib \
  -Dwarning_level=1

meson compile -C build -j "${CPU_COUNT:-2}"
meson install -C build

test -x "${PREFIX}/bin/gjp_quad" || test -f "${PREFIX}/lib/libGaussJacobiQaud"* || test -f "${PREFIX}/lib/libgaussjacobiquad"* || ls -la "${PREFIX}/lib" "${PREFIX}/bin"
