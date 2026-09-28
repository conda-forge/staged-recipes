#!/usr/bin/env bash

# Restore values from an outer environment; this may be sourced by any shell.
if [ -n "${CONDA_SWIFT_SWIFT_BACKUP+x}" ]; then
  export SWIFT="${CONDA_SWIFT_SWIFT_BACKUP}"
  unset CONDA_SWIFT_SWIFT_BACKUP
else
  unset SWIFT
fi
if [ -n "${CONDA_SWIFT_SWIFTC_BACKUP+x}" ]; then
  export SWIFTC="${CONDA_SWIFT_SWIFTC_BACKUP}"
  unset CONDA_SWIFT_SWIFTC_BACKUP
else
  unset SWIFTC
fi
if [ -n "${CONDA_SWIFT_SWIFT_EXEC_BACKUP+x}" ]; then
  export SWIFT_EXEC="${CONDA_SWIFT_SWIFT_EXEC_BACKUP}"
  unset CONDA_SWIFT_SWIFT_EXEC_BACKUP
else
  unset SWIFT_EXEC
fi
unset CONDA_SWIFT_COMPILER

true
