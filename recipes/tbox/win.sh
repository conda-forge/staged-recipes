#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

# Remap gcc/g++ toolnames to clang/clangxx so configure uses the clang toolchain
sed -i 's/toolname="gcc"/toolname="clang"/g; s/toolname="gxx"/toolname="clangxx"/g' configure

./configure --generator=gmake --kind=shared --prefix="${PREFIX}"

patch_libtool
export REMOVE_LIB_PREFIX=1

make -j"${CPU_COUNT:-1}"
make install
