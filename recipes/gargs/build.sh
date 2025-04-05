#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go mod init gargs
go mod tidy -e
go build -modcacherw -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w"
go-licenses save . --save_path=license-files
