#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd v2
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w" ./cmd/wails
go-licenses save ./cmd/wails --save_path=${SRC_DIR}/license-files \
    --ignore github.com/wailsapp/wails \
    --ignore github.com/flytam/filenamify

# Manually copy licenses that go-licenses could not download
cp -r ${RECIPE_DIR}/license-files/* ${SRC_DIR}/license-files
