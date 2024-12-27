#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=1

# build command from https://github.com/benbjohnson/litestream/blob/main/.github/workflows/release.linux.yml
# updated tag name to use PKG_VERSION
go build -ldflags "-s -w -extldflags "-static" -X 'main.Version=v${PKG_VERSION}'" -tags osusergo,netgo,sqlite_omit_load_extension -o ${PREFIX}/bin/${PKG_NAME} ./cmd/litestream

go-licenses save . --save_path=license-files