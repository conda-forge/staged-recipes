#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X src.elv.sh/pkg/buildinfo.VersionSuffix=" ./cmd/elvish
go-licenses save ./cmd/elvish --save_path=license-files
