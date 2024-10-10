#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_CFLAGS="-Wno-undef-prefix"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w" ./cmd/gotop
go-licenses save ./cmd/gotop --save_path=license-files \
    --ignore github.com/xxxserxxx/gotop/v4 \
    --ignore github.com/xxxserxxx/gotop/v4/colorschemes \
    --ignore github.com/xxxserxxx/gotop/v4/devices \
    --ignore github.com/xxxserxxx/gotop/v4/termui \
    --ignore github.com/xxxserxxx/gotop/v4/utils \
    --ignore github.com/xxxserxxx/gotop/v4/widgets \
    --ignore github.com/xxxserxxx/gotop/v4/termui/drawille-go
