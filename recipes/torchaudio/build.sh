#!/bin/bash

set -ex

# copied from pytorch feedstock; what are they for?
# not sure this even makes sense, because upstream adds it again
# https://github.com/pytorch/audio/blob/v0.10.0/third_party/CMakeLists.txt#L3
export CFLAGS="$(echo $CFLAGS | sed 's/-fvisibility-inlines-hidden//g')"
export CXXFLAGS="$(echo $CXXFLAGS | sed 's/-fvisibility-inlines-hidden//g')"

declare -a CUDA_CONFIG_ARGS
if [[ ${cuda_compiler_version} != "None" ]]; then
    if [[ ${cuda_compiler_version} == 11.2 ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6"
    else
        echo "unsupported cuda version. edit build.sh"
        exit 1
    fi

    export USE_CUDA="ON"
fi

# set integration knobs, c.f.
# https://github.com/pytorch/audio/blob/v0.10.0/build_tools/setup_helpers/extension.py#L37-L39
# used in various places, e.g.
# vendored sources: https://github.com/pytorch/audio/tree/main/third_party
# integrations: https://github.com/pytorch/audio/tree/main/torchaudio/csrc

# kaldi is a weird case, see https://github.com/pytorch/audio/issues/1269
export BUILD_KALDI=0
# conflicting patches between torchaudio & upstream sox
export BUILD_SOX=0
# doesn't contain vendored sources
export BUILD_RNNT=1

export CMAKE_C_COMPILER="$CC"
export CMAKE_CXX_COMPILER="$CXX"
export CMAKE_GENERATOR="Ninja"
# help internally called CMake find our pytorch
export Torch_DIR=$SP_DIR/torch/share/cmake/Torch
export bzip2_DIR=$PREFIX
export lzma_DIR=$PREFIX
export zlib_DIR=$PREFIX


python -m pip install . -vv
