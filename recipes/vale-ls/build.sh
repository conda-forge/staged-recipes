#!/usr/bin/env bash

set -eux

module="github.com/errata-ai/vale-ls"

export GOPATH="$( pwd )"
export GOROOT="${BUILD_PREFIX}/go"
export GO_EXTLINK_ENABLED=1
export CGO_ENABLED=1
export GO111MODULE=on

which go
env | grep GOROOT
go version

pushd "src/${module}"
    # go get -v "./cmd/${PKG_NAME}"
    go build \
        -buildmode=pie \
        -ldflags "-s -w -X main.version=${PKG_VERSION}" \
        -o "${PREFIX}/bin/${PKG_NAME}" \
        "./cmd/${PKG_NAME}" \
        || exit 1
    go-licenses save "./cmd/${PKG_NAME}" \
        --save_path "${SRC_DIR}/license-files" \
        --ignore=github.com/xi2/xz \
        || exit 1
popd

# Make GOPATH directories writeable so conda-build can clean everything up.
find "$( go env GOPATH )" -type d -exec chmod +w {} \;
