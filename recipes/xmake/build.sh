#!/bin/bash
set -euxo pipefail

cd "${SRC_DIR}"

# Apply the build-system adaptations consistently in POSIX and MSYS builds.
patch -p1 -i "${RECIPE_DIR}/0001-use-system-lua-lz4-and-tbox.patch"
patch -p1 -i "${RECIPE_DIR}/0002-support-conda-clang-on-windows.patch"

# Recognize conda's target-prefixed compiler driver names.
if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' '/^        cc) toolname="gcc";;$/i\
        *-cc) toolname="clang";;' configure
    sed -i '' '/^        c++) toolname="gxx";;$/i\
        *-c++) toolname="clangxx";;' configure
else
    sed -i 's/        cc) toolname="gcc";;/        *-cc) toolname="gcc";;\n        cc) toolname="gcc";;/' configure
    sed -i 's/        c++) toolname="gxx";;/        *-c++) toolname="gxx";;\n        c++) toolname="gxx";;/' configure
fi

./configure \
    --generator=ninja \
    --external=y \
    --runtime=lua \
    --prefix="${PREFIX}"

if [[ "$(uname)" == "Darwin" ]]; then
    # xcodebuild can emit DVTSDK warnings into the detected SDK path, leaving
    # invalid multiline values in build.ninja.
    python3 -c "
import re
from pathlib import Path

path = Path('build.ninja')
content = path.read_text()
content = re.sub(
    r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+ xcodebuild\[[^\n]*\n',
    '',
    content,
)
path.write_text(content)
"
fi

ninja -j"${CPU_COUNT:-1}"
ninja install

mkdir -p "${PREFIX}/share/man/man1"
install -m 644 scripts/man/xmake.1 "${PREFIX}/share/man/man1/xmake.1"
install -m 644 scripts/man/xrepo.1 "${PREFIX}/share/man/man1/xrepo.1"

mkdir -p "${PREFIX}/share/bash-completion/completions"
install -m 644 xmake/scripts/completions/register-completions.bash \
    "${PREFIX}/share/bash-completion/completions/xmake"

mkdir -p "${PREFIX}/share/fish/vendor_completions.d"
install -m 644 xmake/scripts/completions/register-completions.fish \
    "${PREFIX}/share/fish/vendor_completions.d/xmake.fish"

mkdir -p "${PREFIX}/share/zsh/site-functions"
install -m 644 xmake/scripts/completions/register-completions.zsh \
    "${PREFIX}/share/zsh/site-functions/_xmake"
