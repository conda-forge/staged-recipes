#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w" ./cmd/vale
go-licenses save ./cmd/vale --save_path=license-files --ignore github.com/xi2/xz
