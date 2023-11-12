#!/bin/bash

set -ex

# See https://github.com/horovod/horovod/issues/3956
flatc -c -o horovod/common/wire horovod/common/wire/message.fbs

if [[ ${cuda_compiler_version} != "None" ]]; then
    export HOROVOD_GPU_OPERATIONS=NCCL
    export HOROVOD_NCCL_LINK=SHARED
    export HOROVOD_CUDA_HOME=/usr/local/cuda
fi
export HOROVOD_WITH_TENSORFLOW=1
export HOROVOD_WITH_PYTORCH=1
# mxnet is not available on conda-forge
# https://github.com/conda-forge/staged-recipes/issues/4447
export HOROVOD_WITHOUT_MXNET=1
export HOROVOD_WITH_MPI=1
# gloo is not avaiable on conda-forge
export HOROVOD_WITHOUT_GLOO=1
if [[ "${target_platform}" == osx-* ]]; then
    # https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi
python -m pip install . -vv