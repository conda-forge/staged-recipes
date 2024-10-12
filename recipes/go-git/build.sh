#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd cli/go-git
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w"
go-licenses save . --save_path=${SRC_DIR}/license-files --ignore=github.com/go-git
