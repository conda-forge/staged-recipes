#!/usr/bin/env bash
set -eux

module="github.com/errata-ai/vale"

export GOPATH="$( pwd )"
export GOROOT="${BUILD_PREFIX}/go"
export GOOS=windows
export GOARCH=amd64
export CGO_ENABLED=1
export GO111MODULE=on

pushd "src/${module}"
    go get -u -v "./cmd/${PKG_NAME}"
    go build \
        -ldflags "-s -w -X main.version=${PKG_VERSION}" \
        -o "${PREFIX}/bin/${PKG_NAME}.exe" \
        "./cmd/${PKG_NAME}" \
        || exit 1
    # the --ignores are all stdlib, found for some reason
    go-licenses save "./cmd/${PKG_NAME}" \
        --save_path "${SRC_DIR}/license-files" \
        || exit 1
popd

# Make GOPATH directories writeable so conda-build can clean everything up.
find "$( go env GOPATH )" -type d -exec chmod +w {} \;
