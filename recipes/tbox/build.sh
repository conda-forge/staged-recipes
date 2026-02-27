#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

# Patch configure to recognize conda's *-cc and *-c++ compiler names
# Anchor with 8 leading spaces so sed doesn't match inside *-gcc), */gcc), etc.
if [[ "$(uname)" == "Darwin" ]]; then
    sed -i 's/        cc) toolname="clang";;/        *-cc) toolname="clang";;\n        cc) toolname="clang";;/' configure
    sed -i 's/        c++) toolname="clangxx";;/        *-c++) toolname="clangxx";;\n        c++) toolname="clangxx";;/' configure
else
    sed -i 's/        cc) toolname="gcc";;/        *-cc) toolname="gcc";;\n        cc) toolname="gcc";;/' configure
    sed -i 's/        c++) toolname="gxx";;/        *-c++) toolname="gxx";;\n        c++) toolname="gxx";;/' configure
fi

./configure --generator=ninja --kind=shared --prefix="${PREFIX}"

ninja install -j"${CPU_COUNT:-1}"
