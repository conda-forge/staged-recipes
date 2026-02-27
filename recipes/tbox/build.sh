#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

# Patch configure to recognize conda's *-cc and *-c++ compiler names
if [[ "$(uname)" == "Darwin" ]]; then
    sed -i.bak 's/cc) toolname="gcc";;/*-cc) toolname="clang";;\n        cc) toolname="gcc";;/' configure
    sed -i.bak 's/c++) toolname="gxx";;/*-c++) toolname="clangxx";;\n        c++) toolname="gxx";;/' configure
else
    sed -i 's/cc) toolname="gcc";;/*-cc) toolname="gcc";;\n        cc) toolname="gcc";;/' configure
    sed -i 's/c++) toolname="gxx";;/*-c++) toolname="gxx";;\n        c++) toolname="gxx";;/' configure
fi

CC="${CC}" CXX="${CXX}" ./configure --kind=shared --prefix="${PREFIX}"

make -j"${CPU_COUNT:-1}"
make install PREFIX="${PREFIX}"
