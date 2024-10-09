#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export GOPROXY=https://proxy.golang.org
go mod init
go mod tidy
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/ccat -ldflags="-s -w"
go-licenses save . --save_path=license-files
