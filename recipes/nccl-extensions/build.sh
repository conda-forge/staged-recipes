#!/bin/bash
set -euxo pipefail

export CUDA_HOME="${BUILD_PREFIX}"
export NCCL_HOME="${PREFIX}"
# target_platform is supplied by rattler-build.
# shellcheck disable=SC2154
case "${target_platform}" in
    linux-64) cuda_target=x86_64-linux ;;
    linux-aarch64) cuda_target=aarch64-linux ;;
    *) echo "Unsupported CUDA target: ${target_platform}" >&2; exit 1 ;;
esac
export CUDA_INC="${PREFIX}/targets/${cuda_target}/include"
unset NVCC_GENCODE
export MAKEFLAGS="-j${CPU_COUNT}"

# Record the installed JIT headers, not the temporary source tree. Rattler
# relocates these host-prefix paths in both config.h and the shared library.
mkdir -p "${PREFIX}/include/nccl_ep"
cat > "${PREFIX}/include/nccl_ep/config.h" <<EOF
#pragma once
#define NCCL_EP_JIT_NVCC "${PREFIX}/bin/nvcc"
#define NCCL_EP_JIT_SOURCE_DIR "${PREFIX}/include/nccl_ep"
#define NCCL_EP_JIT_BUILD_INCLUDE_DIR "${PREFIX}/include"
#define NCCL_EP_JIT_CUDA_INCLUDE_DIR "${CUDA_INC}"
EOF
# Upstream passes LDFLAGS directly to nvcc.
host_ldflags="${LDFLAGS}"
export LDFLAGS="${LDFLAGS//-Wl,/-Xlinker }"
make -C nccl_ep build BUILDDIR="${PREFIX}"
export LDFLAGS="${host_ldflags}"

# CMake provides M2N's shared/static libraries and exported CMake targets.
# CMAKE_ARGS is a list of arguments supplied by compiler activation.
# shellcheck disable=SC2086
cmake -S nccl_m2n -B build-m2n -G Ninja ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_CUDA_RUNTIME_LIBRARY=Shared \
    -DNCCL_HOME="${PREFIX}" \
    -DNCCL_M2N_BUILD_TESTS=OFF \
    -DNCCL_M2N_BUILD_BENCH=OFF
cmake --build build-m2n --parallel "${CPU_COUNT}"
cmake --install build-m2n
# Object files are build artifacts, not package contents.
rm -rf "${PREFIX}/obj"
