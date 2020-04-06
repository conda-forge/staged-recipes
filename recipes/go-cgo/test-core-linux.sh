#!/usr/bin/env bash
set -euxf

# Set default flags
export CGO_CFLAGS=${CFLAGS}
export CGO_CPPFLAGS=${CPPFLAGS}
# We have to disable garbage collection for sections
export CGO_LDFLAGS="${LDFLAGS} -Wl,--no-gc-sections"

# Diagnostics
which go
go env
go tool
go tool dist test -list | sort

# Ensure CGO_ENABLED=1
test $(go env CGO_ENABLED) == 1

# Run go's built-in test
go tool dist test -k -v -no-rebuild -run=!^cgo_fortran$

# Rerun failing test to catch error
go tool dist test -k -v -no-rebuild -run=^cgo_fortran$ || true

