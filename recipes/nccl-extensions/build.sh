#!/bin/bash
set -euxo pipefail

export CUDA_HOME="${BUILD_PREFIX}"
export NCCL_HOME="${PREFIX}"
# Record the relocatable host headers in EP's runtime JIT configuration.
case "${target_platform}" in
    linux-64) cuda_target=x86_64-linux ;;
    linux-aarch64) cuda_target=aarch64-linux ;;
    *) echo "Unsupported CUDA target: ${target_platform}" >&2; exit 1 ;;
esac
export CUDA_INC="${PREFIX}/targets/${cuda_target}/include"
# Use EP's supported GPU architectures rather than the compiler activation defaults.
unset NVCC_GENCODE
export MAKEFLAGS="-j${CPU_COUNT}"

# Upstream passes LDFLAGS directly to nvcc, which needs -Xlinker in place
# of the host compiler's -Wl, spelling.
host_ldflags="${LDFLAGS}"
export LDFLAGS="${LDFLAGS//-Wl,/-Xlinker }"
for library in nccl_ep nccl_m2n; do
    make -C "${library}" build BUILDDIR="${SRC_DIR}/build/${library}"
    package="python/nccl/${library#nccl_}"
    mkdir -p "${package}/lib/cu${cuda_compiler_version%%.*}"
    cp -a "build/${library}/include" "${package}/"
    cp -L "build/${library}/lib/lib${library}.so" \
        "${package}/lib/cu${cuda_compiler_version%%.*}/"
done
export LDFLAGS="${host_ldflags}"
"${PYTHON}" -m pip install ./python --no-deps --no-build-isolation -vv
