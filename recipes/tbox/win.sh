#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

sed -i '' '/^        cc) toolname="clang";;$/i\ 
         *-cc) toolname="clang";;' configure 
sed -i '' '/^        c++) toolname="clangxx";;$/i\ 
         *-c++) toolname="clangxx";;' configure

./configure --generator=gmake --kind=shared --prefix="${PREFIX}"

patch_libtool
export REMOVE_LIB_PREFIX=1

make -j"${CPU_COUNT:-1}"
make install
