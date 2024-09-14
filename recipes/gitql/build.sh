#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w"
go-licenses save . --save_path=license-files --ignore=github.com/pjbgf/sha1cd

# Manually copy licenses that go-licenses could not download
cp -r ${RECIPE_DIR}/license-files/* ${SRC_DIR}/license-files
