#!/usr/bin/env bash

set -euo pipefail

export SYMMETRIX_CUDA_ARCH_NUMBER=80
export SYMMETRIX_KOKKOS_ARCH=AMPERE80

exec "${RECIPE_DIR}/build.sh"
