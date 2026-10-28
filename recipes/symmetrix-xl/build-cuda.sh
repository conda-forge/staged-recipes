#!/usr/bin/env bash

set -euo pipefail

: "${SYMMETRIX_BACKEND_SELECTOR:?must select a backend package}"
: "${SYMMETRIX_BACKEND_ARCHITECTURE:?must select a CUDA architecture}"
: "${SYMMETRIX_CUDA_ARCH_NUMBER:?must select a CUDA architecture number}"
: "${SYMMETRIX_KOKKOS_ARCH:?must select a Kokkos architecture}"

module_token=${SYMMETRIX_BACKEND_SELECTOR//-/_}
backend_project="${SRC_DIR}/backend-${SYMMETRIX_BACKEND_SELECTOR}"
backend_package="symmetrix_backend_${module_token}"
distribution="symmetrix-xl-${SYMMETRIX_BACKEND_SELECTOR}"
nvcc_wrapper="${SRC_DIR}/libsymmetrix/external/kokkos/bin/nvcc_wrapper"
host_cxx="${CXX}"

test -x "${nvcc_wrapper}"
cp -R "${RECIPE_DIR}/backend-${SYMMETRIX_BACKEND_SELECTOR}" "${backend_project}"

export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT:-2}"
export CMAKE_GENERATOR="Unix Makefiles"
export CUDA_PATH="${BUILD_PREFIX}"
export CUDA_ROOT="${BUILD_PREFIX}"
export CUDAToolkit_ROOT="${BUILD_PREFIX}"
export CUDACXX="${CUDACXX:-${BUILD_PREFIX}/bin/nvcc}"
export CXX="${nvcc_wrapper}"
export NVCC_WRAPPER_DEFAULT_COMPILER="${host_cxx}"

"${PYTHON}" -m pip install "${backend_project}" \
  --no-deps \
  --no-build-isolation \
  --verbose \
  --config-settings=build-dir="${SRC_DIR}/build-${SYMMETRIX_BACKEND_SELECTOR}" \
  --config-settings=cmake.define.CMAKE_BUILD_TYPE=Release \
  --config-settings=cmake.define.CMAKE_CXX_COMPILER="${nvcc_wrapper}" \
  --config-settings=cmake.define.CMAKE_CUDA_COMPILER="${CUDACXX}" \
  --config-settings=cmake.define.CMAKE_CUDA_HOST_COMPILER="${NVCC_WRAPPER_DEFAULT_COMPILER}" \
  --config-settings=cmake.define.CMAKE_CUDA_ARCHITECTURES="${SYMMETRIX_CUDA_ARCH_NUMBER}" \
  --config-settings=cmake.define.CUDAToolkit_ROOT="${BUILD_PREFIX}" \
  --config-settings=cmake.define.KokkosKernels_CUDA_MATH_INCLUDE_DIR="${PREFIX}/targets/x86_64-linux/include" \
  --config-settings=cmake.define.Python_EXECUTABLE="${PYTHON}" \
  --config-settings=cmake.define.PYTHON_EXECUTABLE="${PYTHON}" \
  --config-settings=cmake.define.SYMMETRIX_REDACT_BUILD_PATHS=ON \
  --config-settings=cmake.define.SYMMETRIX_DEVICE_BACKEND=CUDA \
  --config-settings=cmake.define.SYMMETRIX_KOKKOS=ON \
  --config-settings=cmake.define.SYMMETRIX_HOST_ARCH=none \
  --config-settings=cmake.define.SYMMETRIX_PYTHON_MODULE_NAME="_native_${module_token}" \
  --config-settings=cmake.define.SYMMETRIX_PYTHON_INSTALL_PACKAGE="${backend_package}" \
  --config-settings=cmake.define.SYMMETRIX_DISTRIBUTION_NAME="${distribution}" \
  --config-settings=cmake.define.SYMMETRIX_FRONTEND_VERSION=0.1.1 \
  --config-settings=cmake.define.SYMMETRIX_BACKEND_SELECTOR="${SYMMETRIX_BACKEND_SELECTOR}" \
  --config-settings=cmake.define.SYMMETRIX_BACKEND_ARCHITECTURE="${SYMMETRIX_BACKEND_ARCHITECTURE}" \
  --config-settings=cmake.define.Kokkos_ARCH_NATIVE=OFF \
  --config-settings="cmake.define.Kokkos_ARCH_${SYMMETRIX_KOKKOS_ARCH}=ON" \
  --config-settings=cmake.define.Kokkos_ENABLE_CUDA=ON \
  --config-settings=cmake.define.Kokkos_ENABLE_HIP=OFF \
  --config-settings=cmake.define.Kokkos_ENABLE_OPENMP=OFF \
  --config-settings=cmake.define.Kokkos_ENABLE_SERIAL=ON \
  --config-settings=cmake.define.KokkosKernels_INST_DOUBLE=OFF \
  --config-settings=cmake.define.KokkosKernels_INST_LAYOUTLEFT=OFF \
  --config-settings=cmake.define.KokkosKernels_ENABLE_TPL_CUSPARSE=OFF \
  --config-settings=cmake.define.KokkosKernels_ENABLE_TPL_CUSOLVER=OFF \
  --config-settings=cmake.define.SYMMETRIX_BLAS_LIBRARY="${PREFIX}/lib/libblas.so" \
  --config-settings=cmake.define.SYMMETRIX_BLAS_INCLUDE_DIR="${SRC_DIR}/libsymmetrix/external/cblas-prototypes" \
  --config-settings=cmake.define.SYMMETRIX_SPHERICART_CUDA=ON \
  --config-settings=cmake.define.SPHERICART_ENABLE_CUDA=ON \
  --config-settings=cmake.define.SPHERICART_OPENMP=OFF
