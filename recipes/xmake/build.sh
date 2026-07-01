#!/bin/bash
set -euxo pipefail

cd "${SRC_DIR}"

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

# On Linux, sv and xmake are built as shared libraries (libsv.so / libxmake.so,
# see 0004-*.patch) so nothing third-party is statically linked into the xmake
# binary. `ninja install` only installs default targets and these are
# set_default false, so copy them into $PREFIX/lib ourselves. The cli rpath
# ($ORIGIN/../lib) and libxmake.so's own $ORIGIN rpath then resolve them (and the
# co-installed libtbox/liblua/...) from there.
if [[ "$(uname)" == "Linux" ]]; then
    for name in libsv.so libxmake.so; do
        lib=$(find build -type f -name "${name}" | head -1)
        test -n "${lib}"
        install -Dm755 "${lib}" "${PREFIX}/lib/${name}"
    done
    # The legacy bootstrap generator writes make-style '$$ORIGIN' rpaths that the
    # ninja backend does not unescape, so the baked RUNPATHs are unusable. Replace
    # them with clean, relocatable ones: the binary (bin) looks in ../lib, and
    # libxmake.so looks in its own dir, where libsv.so and the conda-provided
    # libtbox/liblua/... all live.
    patchelf --set-rpath '$ORIGIN/../lib' "${PREFIX}/bin/xmake"
    patchelf --set-rpath '$ORIGIN' "${PREFIX}/lib/libxmake.so"
fi

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
