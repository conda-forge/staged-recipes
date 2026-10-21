#!/usr/bin/env bash

set -euxo pipefail

go build -o="${PREFIX}/bin/forge" -ldflags="-s -w -X github.com/git-pkgs/forge/internal/cli.Version=${PKG_VERSION}" ./cmd/forge

go-licenses save ./cmd/forge --save_path=license-files
