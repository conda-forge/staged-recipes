#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Build the Go binary for 'walk'
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/walk -ldflags="-s -w -X main.Version=${PKG_VERSION}"

# Save licenses of dependencies, ignoring specified packages
go-licenses save . --save_path=license-files --ignore github.com/mattn/go-localereader

