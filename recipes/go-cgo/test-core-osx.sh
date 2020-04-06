#!/usr/bin/env bash
set -euxf

export MACOSX_DEPLOYMENT_TARGET=${GO_MACOSX_DEPLOYMENT_TARGET}
export CGO_CFLAGS=${CFLAGS}
export CGO_CPPFLAGS="${CPPFLAGS} -mmacosx-version-min=${GO_MACOSX_DEPLOYMENT_TARGET} -isysroot ${CONDA_BUILD_SYSROOT}"
export CGO_LDFLAGS="${LDFLAGS}"

# Diagnostics
env | sort
which go
go env
go tool
go tool dist test -list | sort

# All the test passed locally (running macOS 10.15)
go tool dist test -k -v -no-rebuild -run="!^runtime:cpu124|cgo_test$"
go tool dist test -k -v -no-rebuild -run="^runtime:cpu124$"
