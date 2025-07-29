#!/bin/bash
set -euxo pipefail

# The source is extracted into a subdirectory, so we need to cd into it
cd gpq-"${PKG_VERSION}"

# Build the binary
go build -v -o "${PREFIX}/bin/gpq" ./cmd/gpq
