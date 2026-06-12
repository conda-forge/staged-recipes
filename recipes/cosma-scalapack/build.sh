#!/bin/bash
set -ex

# Build COSMA
cmake -B build -S . \
  ${CMAKE_ARGS} \
  -GNinja \
  -DBUILD_SHARED_LIBS="ON" \
  -DCOSMA_BLAS="OPENBLAS" \
  -DCOSMA_SCALAPACK="CUSTOM" \
  -DCOSMA_USE_UNIFIED_MEMORY="OFF" \
  -DCOSMA_WITH_APPS="OFF" \
  -DCOSMA_WITH_BENCHMARKS="OFF" \
  -DCOSMA_WITH_GPU_AWARE_MPI="OFF" \
  -DCOSMA_WITH_NCCL="OFF" \
  -DCOSMA_WITH_PROFILING="OFF" \
  -DCOSMA_WITH_RCCL="OFF" \
  -DCOSMA_WITH_TESTS="OFF"
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
