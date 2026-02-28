#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

sed -i 's/        cc) toolname="gcc";;/        *-cc) toolname="gcc";;\n        cc) toolname="gcc";;/' configure
sed -i 's/        c++) toolname="gxx";;/        *-c++) toolname="gxx";;\n        c++) toolname="gxx";;/' configure

./configure --generator=gmake --kind=shared --prefix="${PREFIX}"

make -j"${CPU_COUNT:-1}"
make install
