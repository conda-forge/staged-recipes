#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/dependabot -ldflags="-s -w" ./cmd/dependabot
go-licenses save ./cmd/dependabot --save_path=license-files
