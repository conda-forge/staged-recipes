#!/usr/bin/env bash
set -euxf

# Diagnostics
go env
go tool
go tool dist test -list | sort

# Ensure GOROOT points to GO under ${CONDA_PREFIX}
test $(go env GOROOT) = ${CONDA_PREFIX}/go

# All the test passed locally (running macOS 10.15)
go tool dist test -k -v -no-rebuild -run=!^runtime:cpu124$ -run=!^cgo_test$
go tool dist test -k -v -no-rebuild -run=^runtime:cpu124$
