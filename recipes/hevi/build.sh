#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Unset environment variables, to prevent the `HttpProxyMissingHost`
# error, as described here: https://github.com/ziglang/zig/issues/21032
unset http_proxy
unset HTTP_PROXY
unset https_proxy
unset HTTPS_PROXY
unset all_proxy
unset ALL_PROXY

# Build the binary
zig build --summary all --verbose -Dcpu=baseline -Dpie=true -Doptimize=ReleaseSafe -p "$PREFIX"
