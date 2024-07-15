#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}"
mkdir -p ${PREFIX}/share/man/man1
go-md2man -in=go-md2man.1.md -out=go-md2man.1
install -m 644 go-md2man.1 ${PREFIX}/share/man/man1
go-licenses save . --save_path=license-files
