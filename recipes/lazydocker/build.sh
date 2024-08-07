#!/bin/bash

set -exuo pipefail

export GO111MODULE=on
export CGO_ENABLED=0

go build -a -v \
    -mod=vendor \
    -ldflags "-s -w -X main.Version=${PKG_VERSION}" \
    -o ${PREFIX}/bin/${PKG_NAME}
