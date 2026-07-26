#!/usr/bin/env bash
set -euxo pipefail

# meson is the authoritative build: the potentials -- the classical pair pots
# and the Fortran 2018 kernels -- are wired there, and it is what installs
# rgpot.pc. The CMake build is a consumer/smoke build carrying a subset.
meson setup builddir \
  --prefix="${PREFIX}" \
  --libdir=lib \
  --buildtype=release \
  -Dwith_rpc=true \
  -Dwith_fortran_pots=enabled \
  -Dwith_eigen=true \
  -Dpure_lib=false \
  -Dwith_cache=false \
  -Dwith_tests=false \
  -Dwith_examples=false

meson compile -C builddir -j "${CPU_COUNT:-2}"
meson install -C builddir
