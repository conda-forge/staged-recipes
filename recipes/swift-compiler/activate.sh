#!/usr/bin/env bash

# Preserve values from an outer environment so deactivation can restore them.
if [ -n "${SWIFT+x}" ]; then export CONDA_SWIFT_SWIFT_BACKUP="${SWIFT}"; fi
if [ -n "${SWIFTC+x}" ]; then export CONDA_SWIFT_SWIFTC_BACKUP="${SWIFTC}"; fi
if [ -n "${SWIFT_EXEC+x}" ]; then export CONDA_SWIFT_SWIFT_EXEC_BACKUP="${SWIFT_EXEC}"; fi

export SWIFT="${CONDA_PREFIX}/bin/swiftc"
export SWIFTC="${SWIFT}"
export SWIFT_EXEC="${CONDA_PREFIX}/libexec/swift/usr/bin/swiftc"
export CONDA_SWIFT_COMPILER=1

# A sourced activation hook must always return success.
true
