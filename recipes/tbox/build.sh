#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

# Create symlinks with names tbox's configure already recognizes
# Conda sets CC/CXX to names like x86_64-conda-linux-gnu-cc which tbox doesn't know
mkdir -p .conda_bin
if [[ "$(uname)" == "Darwin" ]]; then
    ln -sf "$(which "$CC")" .conda_bin/clang
    ln -sf "$(which "$CXX")" .conda_bin/clang++
    export CC=clang CXX=clang++
else
    ln -sf "$(which "$CC")" .conda_bin/gcc
    ln -sf "$(which "$CXX")" .conda_bin/g++
    export CC=gcc CXX=g++
fi
ln -sf "$(which "$AR")" .conda_bin/ar
export PATH="$PWD/.conda_bin:$PATH"

./configure --kind=shared --prefix="${PREFIX}"

make -j"${CPU_COUNT:-1}"
make install PREFIX="${PREFIX}"
