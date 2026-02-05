#!/bin/bash
set -eumx -o pipefail
shopt -s failglob

# Take only those prefixes that are set as variables:
set +u
# shellcheck disable=SC2086
PREFIXES="$PREFIX $BUILD_PREFIX"
set -u
echo "${PREFIXES}"

for dir in $PREFIXES; do
    patch --verbose --batch -u "$dir/x86_64-conda-linux-gnu/sysroot/usr/lib/libc.so" "$PREFIX/libc_linux.patch"
    patch --verbose --batch -u "$dir/x86_64-conda-linux-gnu/sysroot/usr/lib64/libpthread.so" "$PREFIX/libpthread_linux.patch"
done
