#!/bin/bash
set -ex

# conda-forge's CUDA 12+ stack places headers under a target-specific dir:
#   $BUILD_PREFIX/targets/<arch>-linux/include/{cuda.h, cuda_runtime_api.h, ...}
# setup.py computes CUDA_INC as $CUDA_HOME/include, so we point CUDA_HOME at
# that target dir. nccl.h comes from the `nccl` host dep at $PREFIX/include,
# which is picked up by conda-build's default CPPFLAGS.
case "${target_platform}" in
  linux-64)
    targetsDir="targets/x86_64-linux"
    ;;
  linux-aarch64)
    if [[ "${arm_variant_type}" != "sbsa" ]]; then
      echo "Unsupported arm_variant_type: ${arm_variant_type}" >&2
      exit 1
    fi
    targetsDir="targets/sbsa-linux"
    ;;
  *)
    echo "Unsupported target_platform: ${target_platform}" >&2
    exit 1
    ;;
esac

export CUDA_HOME="${BUILD_PREFIX}/${targetsDir}"

cd nccl4py
$PYTHON -m pip install . --no-deps --no-build-isolation -vv
