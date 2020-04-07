#!/usr/bin/env bash
set -euxf

# Test we are running GO under $CONDA_PREFIX
test "$(which go)" == "${CONDA_PREFIX}/bin/go"

# Ensure CGO_ENABLED=1
test "$(go env CGO_ENABLED)" == 1


# Set the CGO Compiler flags
# TODO: This step should not be necessary
export CGO_CFLAGS=${CFLAGS}
export CGO_CPPFLAGS=${CPPFLAGS}
export CGO_LDFLAGS=${LDFLAGS}
case $(uname -s) in
  Darwin)
    # Tell it where to find the MacOS SDK
    export CGO_CPPFLAGS="${CGO_CPPFLAGS} -isysroot ${CONDA_BUILD_SYSROOT}"
    ;;
  Linux)
    # We have to disable garbage collection for sections
    export CGO_LDFLAGS="${CGO_LDFLAGS} -Wl,--no-gc-sections"
    ;;
  *)
    echo "Unknown OS: $(uname -s)"
    exit 1
    ;;
esac


# Print Diagnostics
go env


# Run go's built-in test
case $(uname -s) in
  Darwin)
    # Expect PASS
    go tool dist test -k -v -no-rebuild -run='!^runtime:cpu124$'
    go tool dist test -k -v -no-rebuild -run='^runtime:cpu124'
    # Expect FAIL
    test ! go tool dist test -k -v -no-rebuild -run='!^cgo_test$'
    ;;
  Linux)
    # Expect PASS
    go tool dist test -k -v -no-rebuild -run=!^cgo_fortran$
    # Expect FAIL
    test ! go tool dist test -k -v -no-rebuild -run=^cgo_fortran$
    ;;
esac

