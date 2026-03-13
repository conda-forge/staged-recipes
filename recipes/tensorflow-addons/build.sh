#!/bin/bash

set -ex

export PATH="$PWD:$PATH"
export CC=$(basename $CC)
export CXX=$(basename $CXX)
export LIBDIR=$PREFIX/lib
export INCLUDEDIR=$PREFIX/include

export TF_NEED_CUDA=0

if [[ ${cuda_compiler_version} != "None" ]]; then
    export TF_NEED_CUDA=1
    export TF_CUDA_PATHS="${PREFIX},${CUDA_HOME}"
    export TF_CUDA_VERSION="${cuda_compiler_version}"
    export TF_CUDNN_VERSION="${cudnn}"
    export GCC_HOST_COMPILER_PATH="${GCC}"
    export CUDA_TOOLKIT_PATH="${CUDA_HOME}"
    export CUDNN_INSTALL_PATH="${PREFIX}"

    # addons uses a different nomenclature for compute capabilities than tf proper, see
    # https://github.com/tensorflow/addons/blob/v0.14.0/build_deps/toolchains/gpu/cuda_configure.bzl#L18-L19
    if [[ ${cuda_compiler_version} == 10.* ]]; then
        export TF_CUDA_COMPUTE_CAPABILITIES=3.5,5.0,6.0,6.2,7.0,7.2,7.5
    elif [[ ${cuda_compiler_version} == 11.0* ]]; then
        export TF_CUDA_COMPUTE_CAPABILITIES=3.5,5.0,6.0,6.2,7.0,7.2,7.5,8.0
    elif [[ ${cuda_compiler_version} == 11.1 ]]; then
        export TF_CUDA_COMPUTE_CAPABILITIES=3.5,5.0,6.0,6.2,7.0,7.2,7.5,8.0,8.6
    elif [[ ${cuda_compiler_version} == 11.2 ]]; then
        export TF_CUDA_COMPUTE_CAPABILITIES=3.5,5.0,6.0,6.2,7.0,7.2,7.5,8.0,8.6
    else
        echo "unsupported cuda version."
        exit 1
    fi
fi

# This script links project with TensorFlow dependency; creates .bazelrc
python ./configure.py
# ironically, configure.py cannot be configured, so sed it is...
sed -i'' -e "s:TF_HEADER_DIR=.*:TF_HEADER_DIR=\"$PREFIX/include\":" \
    -e "s:TF_SHARED_LIBRARY_DIR=.*:TF_SHARED_LIBRARY_DIR=\"$PREFIX/lib\":" \
    .bazelrc
if [[ ${cuda_compiler_version} != "None" ]]; then
cat <<EOF >> .bazelrc
# This syntax exposes the variable from the .envrc environment.
# https://bazel.build/designs/2016/06/21/environment.html#new-flag---action_env
build --action_env TF_HEADER_DIR
build --action_env TF_SHARED_LIBRARY_DIR
build --action_env TF_SHARED_LIBRARY_NAME
build --action_env TF_CXX11_ABI_FLAG
build --action_env TF_CUDA_COMPUTE_CAPABILITIES
EOF
fi

# show result (& sleep to allow log to catch up)
cat .bazelrc
sleep 2

# use conda-forge wrapper for bazel, called bazel-toolchain
source gen-bazel-toolchain
bazel build \
    --crosstool_top=//bazel_toolchain:toolchain \
    --copt="-I$SP_DIR/tensorflow/include" \
    build_pip_pkg

# build a whl file
mkdir -p $SRC_DIR/tf_addons_pkg
bash -x bazel-bin/build_pip_pkg $SRC_DIR/tf_addons_pkg

pip install tf_addons_pkg/tensorflow_addons-*.whl
