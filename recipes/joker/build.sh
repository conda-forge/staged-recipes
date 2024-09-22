#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go generate ./...
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X main.version=v${PKG_VERSION}"
go-licenses save . --save_path=license-files --ignore github.com/candid82/joker
