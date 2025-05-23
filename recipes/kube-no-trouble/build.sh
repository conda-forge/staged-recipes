#!/usr/bin/env bash

set -euo pipefail

go build -buildmode=pie -trimpath -o ${PREFIX}/bin/kubent -ldflags="-w -s -X main.version=${PKG_VERSION} -X main.gitSha=conda-forge" ./cmd/kubent
go-licenses save ./cmd/kubent --save_path=license-files
