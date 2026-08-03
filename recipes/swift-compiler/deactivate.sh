#!/usr/bin/env bash

unset SWIFT
unset SWIFTC
unset SWIFT_EXEC
unset CONDA_SWIFT_COMPILER

if [[ -n "${CONDA_SWIFTFLAGS_SET:-}" ]]; then
  if [[ -n "${CONDA_SWIFTFLAGS_BACKUP:-}" ]]; then
    export SWIFTFLAGS="${CONDA_SWIFTFLAGS_BACKUP}"
  else
    unset SWIFTFLAGS
  fi
  unset CONDA_SWIFTFLAGS_BACKUP
  unset CONDA_SWIFTFLAGS_SET
fi

true
