#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Remove any pre-existing license-files directory to avoid conflicts.
rm -rf license-files

# Save licenses of dependencies, ignoring specified packages
go-licenses save . --save_path=license-files --ignore github.com/mattn/go-localereader

# Download the upstream license for go-localereader into the license-files directory.
curl -L https://raw.githubusercontent.com/mattn/go-localereader/master/LICENSE -o license-files/go-localereader.LICENSE

# Build the Go binary for 'walk'
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/walk -ldflags="-s -w -X main.Version=${PKG_VERSION}"