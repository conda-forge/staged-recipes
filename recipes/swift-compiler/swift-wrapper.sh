#!/usr/bin/env bash
set -e

bin_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
prefix="${bin_dir%/bin}"
tool="$(basename -- "$0")"
export SWIFT_EXEC="${SWIFT_EXEC:-${prefix}/libexec/swift/usr/bin/swiftc}"
exec "${prefix}/libexec/swift/usr/bin/${tool}" "$@"
