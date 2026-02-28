#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

sed -i 's/        cc) toolname="gcc";;/        *-cc) toolname="clang";;\n        cc) toolname="clang";;/' configure
sed -i 's/        c++) toolname="gxx";;/        *-c++) toolname="clangxx";;\n        c++) toolname="clangxx";;/' configure
# Strip .exe suffix so path_toolname() can match Windows compiler names (e.g. clang.exe)
sed -i 's/    local toolname=""/    local toolname=""\n    1="${1%.exe}"/' configure

./configure --generator=gmake --kind=shared --prefix="${PREFIX}"

patch_libtool
export REMOVE_LIB_PREFIX=1

make -j"${CPU_COUNT:-1}"
make install
