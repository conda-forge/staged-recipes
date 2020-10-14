#!/usr/bin/env bash
#http://redsymbol.net/articles/unofficial-bash-strict-mode/

set -euo pipefail
IFS=$'\n\t'

set -x

bazel build --config=release //${PKG_NAME}:${PKG_NAME}

# Install Binary into PREFIX/bin
mkdir -p $PREFIX/bin
cp --dereference bazel-bin/${PKG_NAME}/${PKG_NAME} $PREFIX/bin/${PKG_NAME}
