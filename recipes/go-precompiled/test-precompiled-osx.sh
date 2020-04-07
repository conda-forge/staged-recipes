#!/usr/bin/env bash
set -euxf

# Diagnostics
go env
go tool
go tool dist test -list | sort

# All the test passed locally (running macOS 10.15)
go tool dist test -k -v -no-rebuild -run="!^runtime:cpu124|cgo_test$"
go tool dist test -k -v -no-rebuild -run="^runtime:cpu124$"
