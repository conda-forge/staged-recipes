#!/usr/bin/env bash

set -euo pipefail

go build -buildmode=pie -trimpath -o ${PREFIX}/bin/grr -ldflags="-w -s" ./cmd/grr
go-licenses save ./cmd/grr --save_path=license-files
