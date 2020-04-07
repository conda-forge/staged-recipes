#!/usr/bin/env bash
set -euf

# Set default flags
export CGO_CFLAGS="${CFLAGS}"
export CGO_CPPFLAGS="${CPPFLAGS} -isysroot ${CONDA_BUILD_SYSROOT}"
export CGO_LDFLAGS="${LDFLAGS}"

# Diagnostics
which go
go env
go tool
go tool dist test -list | sort

# Ensure CGO_ENABLED=1
test $(go env CGO_ENABLED) == 1

go tool dist test -k -v -no-rebuild -run='!^runtime:cpu124$'

# Run the tests individually
go tool dist test -k -v -no-rebuild -run='^runtime:cpu124$'
