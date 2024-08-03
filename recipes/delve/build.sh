#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/dlv -ldflags="-s -w" ./cmd/dlv
go-licenses save ./cmd/dlv --save_path=license-files
