#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR"

# Patch configure to recognize conda's *-cc and *-c++ compiler names
# Anchor with 8 leading spaces so sed doesn't match inside *-gcc), */gcc), etc.
if [[ "$(uname)" == "Darwin" ]]; then
    # BSD sed: -i requires '' for no backup, use i\ (insert before) for newlines
    sed -i '' '/^        cc) toolname="clang";;$/i\
        *-cc) toolname="clang";;' configure
    sed -i '' '/^        c++) toolname="clangxx";;$/i\
        *-c++) toolname="clangxx";;' configure
    # Set SDKROOT so configure doesn't call xcodebuild (whose stderr warnings
    # leak into -isysroot values and corrupt the generated ninja file)
    export SDKROOT="$(xcrun --show-sdk-path 2>/dev/null)"
else
    sed -i 's/        cc) toolname="gcc";;/        *-cc) toolname="gcc";;\n        cc) toolname="gcc";;/' configure
    sed -i 's/        c++) toolname="gxx";;/        *-c++) toolname="gxx";;\n        c++) toolname="gxx";;/' configure
fi

./configure --generator=ninja --kind=shared --prefix="${PREFIX}"

ninja install -j"${CPU_COUNT:-1}"
