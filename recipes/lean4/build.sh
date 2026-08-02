#!/usr/bin/env bash
set -euxo pipefail

# Build Lake's archive helper from source. Installing it ourselves also avoids
# Lean's configure-time download of a prebuilt leantar executable.
pushd leangz
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install \
  --force \
  --locked \
  --no-track \
  --root "${PREFIX}" \
  --path . \
  --bin leantar
popd

# The top-level project bootstraps stage1 from the checked-in stage0 sources.
# It only supports Makefile generators. Use conda-forge's libraries, CaDiCaL,
# and compiler rather than allowing any configure-time downloads.
cmake ${CMAKE_ARGS} \
  -G "Unix Makefiles" \
  -S . \
  -B build/release \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCADICAL="${BUILD_PREFIX}/bin/cadical" \
  -DLEANTAR="${PREFIX}/bin/leantar" \
  -DINSTALL_CADICAL=OFF \
  -DINSTALL_LEANTAR=OFF \
  -DSTAGE0_INSTALL_CADICAL=OFF \
  -DSTAGE0_INSTALL_LEANTAR=OFF \
  -DLEANC_CC="$(basename "${CC}")" \
  -DLEAN_EXTRA_LINKER_FLAGS="${LDFLAGS}" \
  -DUSE_MIMALLOC=OFF

cmake --build build/release --parallel "${CPU_COUNT}"
cmake --build build/release/stage1 --target install
