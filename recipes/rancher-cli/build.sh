#!/usr/bin/env bash

set -eux

go build -v \
    -buildmode=pie \
    -trimpath \
    -modcacherw \
    -ldflags="-w -s -X main.VERSION=v$PKG_VERSION -extldflags -static" \
    -o "${PREFIX}/bin/rancher" \
    .

ls "${PREFIX}/bin/rancher"

go-licenses save . --save_path library_licenses
