#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

zig build --summary all --verbose -Dcpu=baseline -Dpie -Doptimize=ReleaseSafe -p "$PREFIX"
