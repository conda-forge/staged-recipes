#!/usr/bin/env bash
set -euxf

# Diagnostics
go env
go tool
go tool dist test -list | sort

# Run go's built-in test
go tool dist test -k -v -no-rebuild -run=!^cgo_fortran$

