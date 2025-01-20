#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

zig build install -p "$PREFIX"
