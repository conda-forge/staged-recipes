#!/usr/bin/env bash

set -euo pipefail

export SYMMETRIX_CUDA_ARCH_NUMBER=120
export SYMMETRIX_KOKKOS_ARCH=BLACKWELL120

exec "${RECIPE_DIR}/build.sh"
