#!/usr/bin/env bash
set -euxo pipefail

configure_args=(--prefix="${PREFIX}")
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" && -n "${CC_FOR_BUILD:-}" ]]; then
  # mawk's configure ignores CC_FOR_BUILD and would otherwise search PATH for a
  # native compiler to build its code generators (makebits, makescan).
  configure_args+=(--with-build-cc="${CC_FOR_BUILD}")
fi

./configure "${configure_args[@]}"
make -j"${CPU_COUNT}"
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" || -n "${CROSSCOMPILING_EMULATOR:-}" ]]; then
  make check
fi
make install
