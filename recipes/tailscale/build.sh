#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd cmd/tailscale

go-licenses save . \
    --save_path ../../library_licenses

go build -v \
    -ldflags "-s -w -X 'tailscale.com/version.shortStamp=$PKG_VERSION'" \
    -o $PREFIX/bin/tailscale
