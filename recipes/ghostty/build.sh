#! /bin/bash

set -ex

export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig

zig build \
  --prefix $PREFIX \
  -Doptimize=ReleaseFast \
  -Dcpu=baseline
