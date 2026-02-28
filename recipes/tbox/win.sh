#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

SRC_UNIX="$(cygpath '%SRC_DIR%')"
BUILD_UNIX="$(cygpath '%BUILD_PREFIX%')"
cd "$SRC_UNIX"
for dir in "$BUILD_UNIX/Library/mingw-w64/bin" "$BUILD_UNIX/mingw64/bin" "$BUILD_UNIX/Library/bin" "$BUILD_UNIX/bin"; do
    if [ -d "$dir" ]; then export PATH="$dir:$PATH"; fi
done

sed -i 's/        cc) toolname="gcc";;/        *-cc) toolname="gcc";;\n        cc) toolname="gcc";;/' configure
sed -i 's/        c++) toolname="gxx";;/        *-c++) toolname="gxx";;\n        c++) toolname="gxx";;/' configure

./configure --generator=gmake --kind=shared --prefix="${PREFIX}"

patch_libtool
export REMOVE_LIB_PREFIX=1

make -j"${CPU_COUNT:-1}"
make install
