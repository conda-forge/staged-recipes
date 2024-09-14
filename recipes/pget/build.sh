#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X main.version=${PKG_VERSION}" ./cmd/${PKG_NAME}
go-licenses save ./cmd/${PKG_NAME} --save_path=license-files
