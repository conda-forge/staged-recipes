#!/usr/bin/env bash
set -euxf

# Diagnostics
go env
go tool
go tool dist test -list | sort

# Run go's built-in test
case $(uname -s) in
  Darwin)
    # Expect PASS
    go tool dist test -k -v -no-rebuild -run='!^runtime:cpu124$'
    go tool dist test -k -v -no-rebuild -run='^runtime:cpu124$'
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

