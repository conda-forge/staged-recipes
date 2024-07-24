#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X github.com/rhysd/actionlint.version=${PKG_VERSION}" ./cmd/${PKG_NAME}
go-licenses save . --save_path=license-files
