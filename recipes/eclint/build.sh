#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/eclint -ldflags="-s -w" ./cmd/eclint
go-licenses save ./cmd/eclint --save_path=license-files
