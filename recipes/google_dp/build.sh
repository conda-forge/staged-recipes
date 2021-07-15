#!/usr/bin/env bash

set -euxo pipefail

pushd cc
bazel build ... --test_output=errors --keep_going --verbose_failures=true //differential-privacy
mkdir ${PREFIX}/bin
cp ./bazel-out/k8-fastbuild-ST-4c64f0b3d5c7/bin/differential-privacy ${PREFIX}/bin