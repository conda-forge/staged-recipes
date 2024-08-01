#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w" ./cmd/${PKG_NAME}
go-licenses save . --save_path=license-files

mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 _${PKG_NAME} ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}
