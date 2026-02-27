#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

# Patch configure to recognize conda's *-cc and *-c++ compiler names
sed -i 's/cc) toolname="gcc";;/*-cc) toolname="gcc";;\n        cc) toolname="gcc";;/' configure
sed -i 's/c++) toolname="gxx";;/*-c++) toolname="gxx";;\n        c++) toolname="gxx";;/' configure

CC="${CC}" CXX="${CXX}" ./configure --kind=shared --prefix="${PREFIX}"

make -j"${CPU_COUNT:-1}"
make install PREFIX="${PREFIX}"
