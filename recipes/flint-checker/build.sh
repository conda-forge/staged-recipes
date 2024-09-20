#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export GOPROXY=https://proxy.golang.org
go mod init flint
go mod edit -replace github.com/codegangsta/cli=github.com/urfave/cli@v1
go mod tidy -e
go mod vendor -e

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/flint -ldflags="-s -w"
go-licenses save . --save_path=license-files
