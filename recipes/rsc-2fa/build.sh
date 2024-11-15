#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go mod vendor
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/2fa -ldflags="-s -w"
go-licenses save . --save_path=license-files
