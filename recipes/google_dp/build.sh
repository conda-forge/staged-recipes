#!/usr/bin/env bash

set -euxo pipefail

pushd cc
bazel build ... --test_output=errors --keep_going --verbose_failures=true 
mkdir ${PREFIX}/bin