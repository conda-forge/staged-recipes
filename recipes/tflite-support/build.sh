#!/bin/bash

set -ex

export PATH="$PWD:$PATH"
export CC=$(basename $CC)
export CXX=$(basename $CXX)
export LIBDIR=$PREFIX/lib
export INCLUDEDIR=$PREFIX/include

source gen-bazel-toolchain
bazel build \
    --crosstool_top=//bazel_toolchain:toolchain \
    --cpu ${TARGET_CPU} \
    tensorflow_lite_support/tools/pip_package/build_pip_pkg

# build a whl file
mkdir -p $SRC_DIR/tflite_support_pkg
bash -x bazel-bin/tensorflow_lite_support/tools/pip_package/build_pip_pkg $SRC_DIR/tflite_support_pkg

pip install tflite_support_pkg/tflite_support-*.whl