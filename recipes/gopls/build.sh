#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w" ./gopls
go-licenses save ./gopls --save_path=license-files --ignore golang.org/x/tools/gopls
