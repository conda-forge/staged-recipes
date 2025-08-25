#!/bin/bash
set -euxo pipefail
go build -v -o "${PREFIX}/bin/gpq" ./cmd/gpq
