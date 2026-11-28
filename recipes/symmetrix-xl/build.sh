#!/usr/bin/env bash

set -euo pipefail

export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT:-2}"
export CMAKE_GENERATOR="Unix Makefiles"

"${PYTHON}" -m pip install "${SRC_DIR}/symmetrix" \
  --no-deps \
  --no-build-isolation \
  --verbose \
  --config-settings=build-dir="${SRC_DIR}/build-cpu" \
  --config-settings=cmake.define.CMAKE_BUILD_TYPE=Release \
  --config-settings=cmake.define.CMAKE_CUDA_COMPILER=NOTFOUND \
  --config-settings=cmake.define.Python_EXECUTABLE="${PYTHON}" \
  --config-settings=cmake.define.PYTHON_EXECUTABLE="${PYTHON}" \
  --config-settings=cmake.define.SYMMETRIX_REDACT_BUILD_PATHS=ON \
  --config-settings=cmake.define.SYMMETRIX_DEVICE_BACKEND=NONE \
  --config-settings=cmake.define.SYMMETRIX_KOKKOS=ON \
  --config-settings=cmake.define.SYMMETRIX_HOST_ARCH=none \
  --config-settings=cmake.define.Kokkos_ARCH_NATIVE=OFF \
  --config-settings=cmake.define.Kokkos_ENABLE_CUDA=OFF \
  --config-settings=cmake.define.Kokkos_ENABLE_HIP=OFF \
  --config-settings=cmake.define.Kokkos_ENABLE_OPENMP=ON \
  --config-settings=cmake.define.Kokkos_ENABLE_SERIAL=OFF \
  --config-settings=cmake.define.KokkosKernels_ENABLE_TPL_BLAS=ON \
  --config-settings=cmake.define.SYMMETRIX_BLAS_LIBRARY="${PREFIX}/lib/libblas.so" \
  --config-settings=cmake.define.SYMMETRIX_BLAS_INCLUDE_DIR="${SRC_DIR}/libsymmetrix/external/cblas-prototypes" \
  --config-settings=cmake.define.SYMMETRIX_SPHERICART_CUDA=OFF \
  --config-settings=cmake.define.SPHERICART_ENABLE_CUDA=OFF
