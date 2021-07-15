#!/bin/bash

set -euxo pipefail

pushd differential-privacy/cc
bazel build ... --test_output=errors --keep_going --verbose_failures=true
popd
mkdir -p $PREFIX/bin
cp ../../bazel-bin/differential-privacy/cc $PREFIX/bin