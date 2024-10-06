#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w" ./cmd/trivy
go-licenses save ./cmd/trivy --save_path=license-files --ignore=github.com/csaf-poc/csaf_distribution --ignore=modernc.org/mathutil
