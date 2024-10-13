#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export GOPROXY=https://proxy.golang.org
go mod init
go mod tidy -e
go mod vendor -e
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w"
go-licenses save . --save_path=license-files
