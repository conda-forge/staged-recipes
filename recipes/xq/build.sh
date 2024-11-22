#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X main.version=${PKG_VERSION}"
go-licenses save . --save_path=license-files
mkdir -p ${PREFIX}/share/man/man1
install -m 644 docs/xq.man ${PREFIX}/share/man/man1/xq.1
