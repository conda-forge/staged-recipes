#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd cmd/golangci-lint

go-licenses save . \
    --save_path ../../library_licenses \
    --ignore github.com/golangci/golangci-lint
go build -v -o $PREFIX/bin/golangci-lint
