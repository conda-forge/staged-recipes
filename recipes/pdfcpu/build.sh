#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X github.com/pdfcpu/pdfcpu/pkg/pdfcpu.VersionStr=${PKG_VERSION}" ./cmd/pdfcpu
go-licenses save ./cmd/pdfcpu --save_path=license-files
