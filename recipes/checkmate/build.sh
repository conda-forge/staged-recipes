#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}"
go-licenses save . --save_path=license-files \
    --ignore github.com/golang/freetype/raster \
    --ignore github.com/golang/freetype/truetype
