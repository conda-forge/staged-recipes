#!/bin/bash

set -exuo pipefail

go build -a -v \
    -ldflags "-s -w -X main.Version=${PKG_VERSION}" \
    -o ${PREFIX}/bin/${PKG_NAME}

go-licenses save . --save_path=./license-files
