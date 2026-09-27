#!/usr/bin/env bash

export SWIFT="${CONDA_PREFIX}/bin/swiftc"
export SWIFTC="${SWIFT}"
export SWIFT_EXEC="${CONDA_PREFIX}/libexec/swift/usr/bin/swiftc"
export CONDA_SWIFT_COMPILER=1

# A sourced activation hook must always return success.
true
