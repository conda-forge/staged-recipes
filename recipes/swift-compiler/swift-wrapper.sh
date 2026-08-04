#!/usr/bin/env bash
set -e

bin_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
prefix="${bin_dir%/bin}"
tool="$(basename -- "$0")"
exec "${prefix}/libexec/swift/bin/${tool}" "$@"
