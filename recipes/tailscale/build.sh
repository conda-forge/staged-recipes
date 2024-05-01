#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd cmd/$PKG_NAME

go-licenses save . \
    --save_path ../../library_licenses

export CGO_ENABLED=0
go build -v \
    -ldflags "-s -w -X 'tailscale.com/version.shortStamp=$PKG_VERSION'" \
    -o $PREFIX/bin/$PKG_NAME
