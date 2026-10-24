#!/usr/bin/env bash

set -euo pipefail

export SYMMETRIX_BACKEND_SELECTOR=cuda12-sm80
export SYMMETRIX_BACKEND_ARCHITECTURE=sm80
export SYMMETRIX_CUDA_ARCH_NUMBER=80
export SYMMETRIX_KOKKOS_ARCH=AMPERE80

exec "${RECIPE_DIR}/build-cuda.sh"
