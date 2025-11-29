#! /bin/bash

set -ex

zig build \
  --prefix $PREFIX \
  -Doptimize=ReleaseFast \
  -Dcpu=baseline
