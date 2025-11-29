#! /bin/bash

set -ex

zig build -p $PREFIX -Doptimize=ReleaseFast
