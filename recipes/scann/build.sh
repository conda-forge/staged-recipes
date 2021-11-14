#!/bin/bash

set -ex

export PATH="$PWD:$PATH"
export CC=$(basename $CC)
export CXX=$(basename $CXX)
export LIBDIR=$PREFIX/lib
export INCLUDEDIR=$PREFIX/include

# This script links project with TensorFlow dependency; creates .bazelrc
python ./configure.py
cat .bazelrc

bazel build -c opt --features=thin_lto \
    # --copt=-mavx2
    # --copt=-mfma
    --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
    # blocked on CUDA>10.2 (not in staged-recipes)
    # --cxxopt="-std=c++17"
    --copt=-fsized-deallocation \
    --copt=-w \
    :build_pip_pkg

# build a whl file
mkdir -p $SRC_DIR/tf_addons_pkg
bash -x bazel-bin/build_pip_pkg $SRC_DIR/tf_addons_pkg

pip install tf_addons_pkg/tensorflow_addons-*.whl
