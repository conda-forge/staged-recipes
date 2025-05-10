#!/usr/bin/env bash

set -euo pipefail

go build -buildmode=pie -trimpath -o ${PREFIX}/bin/jb -ldflags="-w -s" ./cmd/jb
go-licenses save ./cmd/jb --save_path=license-files
