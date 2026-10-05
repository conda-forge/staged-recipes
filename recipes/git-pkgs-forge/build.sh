#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -o="${PREFIX}/bin/forge" -ldflags="-s -w -X github.com/git-pkgs/forge/internal/cli.Version=${PKG_VERSION}" ./cmd/forge

go-licenses save ./cmd/forge --save_path=license-files
