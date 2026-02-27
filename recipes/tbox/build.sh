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
else
    sed -i 's/        cc) toolname="gcc";;/        *-cc) toolname="gcc";;\n        cc) toolname="gcc";;/' configure
    sed -i 's/        c++) toolname="gxx";;/        *-c++) toolname="gxx";;\n        c++) toolname="gxx";;/' configure
fi

./configure --generator=ninja --kind=shared --prefix="${PREFIX}"

if [[ "$(uname)" == "Darwin" ]]; then
    # Fix build.ninja: xcodebuild stderr warnings (DVTSDK: Skipped SDK...) leak
    # into -isysroot values, creating multi-line ninja values that break parsing.
    # Strip the warning lines (timestamp + xcodebuild[...] + message + newline)
    # so the -isysroot path joins correctly with the SDK path on the next line.
    python3 -c "
import re
with open('build.ninja') as f:
    content = f.read()
content = re.sub(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+ xcodebuild\[[^\n]*\n', '', content)
with open('build.ninja', 'w') as f:
    f.write(content)
"
fi

ninja install -j"${CPU_COUNT:-1}"
