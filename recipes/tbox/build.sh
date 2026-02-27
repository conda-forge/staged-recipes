#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

# Patch configure: treat unknown compiler names as gcc (linux) or clang (macOS)
# Conda sets CC to names like x86_64-conda-linux-gnu-cc which tbox doesn't recognize
if [[ "$(uname)" == "Darwin" ]]; then
    sed -i.bak 's/raise "unknown tool ${1}"/toolname="clang"/' configure
else
    sed -i 's/raise "unknown tool ${1}"/toolname="gcc"/' configure
fi

./configure --kind=shared --prefix="${PREFIX}"

make -j"${CPU_COUNT:-1}"
make install PREFIX="${PREFIX}"
