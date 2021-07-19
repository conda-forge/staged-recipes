#!/bin/bash

set -ex

export PATH="$PWD:$PATH"
export CC=$(basename $CC)
export CXX=$(basename $CXX)
export LIBDIR=$PREFIX/lib
export INCLUDEDIR=$PREFIX/include

pushd cc
bazel build ... --logging=6 --subcommands --verbose_failures --crosstool_top=//custom_clang_toolchain:toolchain
popd
mkdir -p $PREFIX/bin
cp bazel-bin/cc $PREFIX/bin