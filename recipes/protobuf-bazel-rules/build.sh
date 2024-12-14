#!/bin/bash

set -euxo pipefail

mkdir -p $PREFIX/share/bazel/protobuf
cp -r bazel $PREFIX/share/bazel/protobuf/
