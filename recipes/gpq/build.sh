#!/bin/bash

set -euxo pipefail

# Build the Go binary
go build -v -o "${PREFIX}"/bin/gpq ./cmd/gpq