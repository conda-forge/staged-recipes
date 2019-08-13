#!/bin/bash

set -ex

# do not build with MKL support
export TF_NEED_MKL=0
export BAZEL_MKL_OPT=""

mkdir -p ./bazel_output_base
export BAZEL_OPTS="--batch "

# Linux
# the following arguments are useful for debugging
#    --logging=6
#    --subcommands

# Set compiler and linker flags as bazel does not account for CFLAGS,
# CXXFLAGS and LDFLAGS.
BUILD_OPTS="
--copt=-march=nocona
--copt=-mtune=haswell
--copt=-ftree-vectorize
--copt=-fPIC
--copt=-fstack-protector-strong
--copt=-O2
--cxxopt=-fvisibility-inlines-hidden
--cxxopt=-fmessage-length=0
--linkopt=-zrelro
--linkopt=-znow
--verbose_failures
${BAZEL_MKL_OPT}
--config=opt"
export TF_ENABLE_XLA=1

# Python settings
export PYTHON_BIN_PATH=${PYTHON}
export PYTHON_LIB_PATH=${SP_DIR}
export USE_DEFAULT_PYTHON_LIB_PATH=1

# additional settings
export CC_OPT_FLAGS="-march=nocona -mtune=haswell"
export TF_NEED_IGNITE=1
export TF_NEED_OPENCL=0
export TF_NEED_OPENCL_SYCL=0
export TF_NEED_CUDA=0
export TF_NEED_ROCM=0
export TF_NEED_MPI=0
export TF_DOWNLOAD_CLANG=0
export TF_SET_ANDROID_WORKSPACE=0
./configure

# build using bazel
bazel ${BAZEL_OPTS} build ${BUILD_OPTS} //tensorflow:libtensorflow.so //tensorflow:libtensorflow_cc.so

