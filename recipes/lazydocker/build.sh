#!/bin/bash

set -exuo pipefail

export GO111MODULE=on
export GOPATH=${SRC_DIR}/go
export PATH=$GOPATH/bin:$PATH
export CGO_ENABLED=0

# PATH を更新
go mod vendor

go build -a -v \
    -mod=vendor \
    -ldflags "-s -w -X main.Version=${PKG_VERSION}" \
    -o ${PREFIX}/bin/${PKG_NAME}
