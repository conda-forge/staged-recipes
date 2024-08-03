#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -trimpath -buildmode=pie -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w" ./cmd/${PKG_NAME}
go-licenses save ./cmd/${PKG_NAME} --save_path=license-files
