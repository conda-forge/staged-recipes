#!/usr/bin/env bash
set -euxf

export MACOSX_DEPLOYMENT_TARGET=${GO_MACOSX_DEPLOYMENT_TARGET}
export CGO_CFLAGS=${CFLAGS}
export CGO_CPPFLAGS="${CPPFLAGS} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
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
