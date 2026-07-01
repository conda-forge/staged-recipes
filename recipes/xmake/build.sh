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

# On Linux and macOS, sv and xmake are shared libraries. `ninja install` only
# installs default targets and these are set_default false, so copy them into
# $PREFIX/lib ourselves.
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
elif [[ "$(uname)" == "Darwin" ]]; then
    mkdir -p "${PREFIX}/lib"
    for name in libsv.dylib libxmake.dylib; do
        lib=$(find build -type f -name "${name}" | head -1)
        test -n "${lib}"
        install -m 755 "${lib}" "${PREFIX}/lib/${name}"
    done

    sv_dylib="${PREFIX}/lib/libsv.dylib"
    xmake_dylib="${PREFIX}/lib/libxmake.dylib"
    xmake_bin="${PREFIX}/bin/xmake"

    # Give the private dylibs relocatable identities, and normalize references
    # in case the legacy generator recorded their paths from the build tree.
    install_name_tool -id '@rpath/libsv.dylib' "${sv_dylib}"
    install_name_tool -id '@rpath/libxmake.dylib' "${xmake_dylib}"

    rewrite_macho_dependency() {
        local file="$1"
        local leaf="$2"
        local replacement="@rpath/${leaf}"
        local dependency

        while IFS= read -r dependency; do
            case "${dependency}" in
                *"/${leaf}"|"${leaf}")
                    if [[ "${dependency}" != "${replacement}" ]]; then
                        install_name_tool -change \
                            "${dependency}" "${replacement}" "${file}"
                    fi
                    ;;
            esac
        done < <(otool -L "${file}" | tail -n +2 | awk '{print $1}')
    }

    rewrite_macho_dependency "${xmake_dylib}" libsv.dylib
    rewrite_macho_dependency "${xmake_bin}" libsv.dylib
    rewrite_macho_dependency "${xmake_bin}" libxmake.dylib

    # Strip build-tree LC_RPATH entries. The executable searches the package's
    # lib directory, while libxmake finds libsv and conda libraries beside it.
    reset_macho_rpaths() {
        local file="$1"
        local replacement="${2:-}"
        local rpath

        while IFS= read -r rpath; do
            if [[ -n "${rpath}" ]]; then
                install_name_tool -delete_rpath "${rpath}" "${file}"
            fi
        done < <(
            otool -l "${file}" |
                awk '$1 == "cmd" && $2 == "LC_RPATH" {getline; getline; print $2}'
        )
        if [[ -n "${replacement}" ]]; then
            install_name_tool -add_rpath "${replacement}" "${file}"
        fi
    }

    reset_macho_rpaths "${sv_dylib}"
    reset_macho_rpaths "${xmake_dylib}" '@loader_path'
    reset_macho_rpaths "${xmake_bin}" '@loader_path/../lib'

    # Fail during the build if the private dependency chain is not relocatable.
    test "$(otool -D "${sv_dylib}" | tail -n 1)" = '@rpath/libsv.dylib'
    test "$(otool -D "${xmake_dylib}" | tail -n 1)" = '@rpath/libxmake.dylib'
    otool -L "${xmake_dylib}" | grep -q '@rpath/libsv.dylib'
    otool -L "${xmake_bin}" | grep -q '@rpath/libxmake.dylib'
    test ! -e "${PREFIX}/lib/libsv.a"
    test ! -e "${PREFIX}/lib/libxmake.a"
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
