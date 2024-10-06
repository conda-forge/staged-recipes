#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go mod init github.com/svent/sift
go mod tidy -e
go mod vendor -e
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w"
go-licenses save . --save_path=license-files --ignore=github.com/svent/sift
