#!/usr/bin/env bash
set -euo pipefail

export CGO_ENABLED=0

go mod download

# Collect licenses of statically linked dependencies (required by conda-forge
# since Go links all dependencies into the binary). Add `--ignore <module>`
# only if a module fails to resolve.
go-licenses save ./cmd/versitygw --save_path library_licenses

install -d "${PREFIX}/bin"

go build \
  -v \
  -trimpath \
  -ldflags "-s -w -X main.Version=v${PKG_VERSION}" \
  -o "${PREFIX}/bin/versitygw" \
  ./cmd/versitygw
