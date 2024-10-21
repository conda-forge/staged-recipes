#!/usr/bin/env bash

set -ex

go build -v \
    -buildmode=pie \
    -trimpath \
    -modcacherw \
    -ldflags="-w -s -X main.VERSION=v$PKG_VERSION -extldflags -static" \
    -o "${PREFIX}/bin/rancher" \
    .

go-licenses save \
    "." \
    --save_path "$SRC_DIR/library_licenses/"
