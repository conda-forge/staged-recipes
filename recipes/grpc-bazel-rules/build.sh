#!/bin/bash

set -euxo pipefail

mkdir -p $PREFIX/share/bazel/grpc
cp -r bazel $PREFIX/share/bazel/grpc/
