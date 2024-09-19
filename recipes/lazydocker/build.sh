#!/bin/bash

set -exuo pipefail

export GO111MODULE=on

go build -a -v \
    -mod=vendor \
    -ldflags "-s -w -X main.Version=${PKG_VERSION}" \
    -o ${PREFIX}/bin/${PKG_NAME}

go-licenses save . --save_path=./license-files
