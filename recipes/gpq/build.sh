#!/bin/bash
set -euxo pipefail

# Build the binary
go build -v -o "${PREFIX}/bin/gpq" .

