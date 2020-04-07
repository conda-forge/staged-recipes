#!/usr/bin/env bash
set -euxf

export CGO_CFLAGS="${CFLAGS}"
export CGO_CPPFLAGS="${CPPFLAGS} -isysroot ${CONDA_BUILD_SYSROOT}"
export CGO_LDFLAGS="${LDFLAGS}"

# Diagnostics
env | sort
which go
go env
go tool
go tool dist test -list | sort

go tool dist test -k -v -no-rebuild -run='!^runtime:cpu124$'

# Run the tests individually
go tool dist test -k -v -no-rebuild -run='^runtime:cpu124$'
