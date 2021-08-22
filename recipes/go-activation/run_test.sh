#!/usr/bin/env bash
set -exuf

# Test variable is set
test "${CONDA_GO_COMPILER}" == 1


# Test GOBIN is set to $PREFIX/bin
test "$(go env GOBIN)" == "$CONDA_PREFIX/bin"


# Test GOPATH is set to SRC-DIR
# We cannot use that here though as conda-build checks for
# the existence of SRC-DIR for an old behaviour change.
test "$(go env GOPATH)" == "${PWD}/gopath"


# Print diagnostics
go env

go mod init example.com/hello_world
go build .
if [[ "${cross_target_platform}" == "${build_platform}" || "${CMAKE_CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ./hello_world
fi
