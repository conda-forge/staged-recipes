#!/bin/bash

set -ex

pushd cc
bazel build ... --logging=6 --subcommands --verbose_failures --crosstool_top=//custom_clang_toolchain:toolchain
popd
mkdir -p $PREFIX/bin
cp bazel-bin/cc $PREFIX/bin