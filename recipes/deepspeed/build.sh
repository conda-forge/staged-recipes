#!/bin/bash
set -ex

# Deepspeed ops cannot be built without CUDA
if [[ ${cuda_compiler_version} != "None" ]]; then
  export DS_BUILD_OPS=1

  # It seems like CUDA_HOME is not set.
  # From https://github.com/conda-forge/arrow-cpp-feedstock/blob/21e42a6c6a9566acebd50cc9efd6d921635204de/recipe/build-arrow.sh#L26

  if [[ -z "${CUDA_HOME+x}" ]]
  then
    echo "cuda_compiler_version=${cuda_compiler_version} CUDA_HOME=$CUDA_HOME"
    CUDA_GDB_EXECUTABLE=$(which cuda-gdb || exit 0)
    if [[ -n "$CUDA_GDB_EXECUTABLE" ]]
    then
        CUDA_HOME=$(dirname $(dirname $CUDA_GDB_EXECUTABLE))
    else
        echo "Cannot determine CUDA_HOME: cuda-gdb not in PATH"
        return 1
    fi
  fi

else
  export DS_BUILD_OPS=0
fi

# Disable sparse_attn since it requires an exact version of triton==1.0.0
export DS_BUILD_SPARSE_ATTN=0

python -m pip install . -vv
