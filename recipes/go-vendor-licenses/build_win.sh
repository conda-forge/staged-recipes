#!/usr/bin/env bash
set -eux

module="github.com/tq-systems/go-vendor-licenses"

export GOPATH="$( pwd )"
export GOROOT="${BUILD_PREFIX}/go"
export GOOS=windows
export GOARCH=amd64
export GO111MODULE=on

pushd "src/${module}"
    go get -v "./cmd/${PKG_NAME}"
    go build \
        -o "${PREFIX}/bin/${PKG_NAME}.exe" \
        "./cmd/${PKG_NAME}" \
        || exit 1
    # except the first, all --ignores are stdlib, found for some reason
    go-licenses save "./cmd/${PKG_NAME}" \
        --save_path "${SRC_DIR}/license-files" \
        || exit 1
popd

# Make GOPATH directories writeable so conda-build can clean everything up.
#
#   TODO: this fails currently... maybe could be batched?
#
#   find: The environment is too large for exec().
#
# find "$( go env GOPATH )" -type d -exec chmod +w {} \;
