#!/bin/bash
set -euxo pipefail

cd "${SRC_DIR}"

# autotools_clang_conda supplies clang targeting the MSVC/UCRT ABI. Even though
# xmake's internal platform name stays "mingw", the toolchain is clang -> lld-link
# and the runtime is UCRT (api-ms-win-crt-*, vcruntime140), not the MinGW CRT.
export CC=clang
export CXX=clang++
export CFLAGS="${CFLAGS} -DNOCRYPT -DNOGDI"
export CXXFLAGS="${CXXFLAGS} -DNOCRYPT -DNOGDI"

./configure \
    --generator=gmake \
    --plat=mingw \
    --toolchain=clang \
    --external=y \
    --runtime=lua \
    --readline=n \
    --curses=n \
    --prefix="${PREFIX}"

# The two internal third-party/private targets (sv, xmake) are built as shared
# libraries on Windows (see 0004-*.patch) so nothing is statically linked into
# xmake.exe:
#   * sv  -> sv.dll  (+ sv.lib import lib)   -- xmake-core-sv, UNLICENSE
#   * xmake -> xmake.dll (+ xmake.lib import lib) -- xmake's own core
# xmake.exe (the cli target) then links against those import libs and loads the
# DLLs at runtime, exactly like it already loads tbox.dll / lua.dll / lz4.dll /
# xxhash.dll. This keeps the package free of shipped static libraries.

BUILD_DIR="build/mingw/x86_64/release"

# The shared-target codepath in the legacy configure/gmake generator appends
# -fPIC, which is rejected by clang on the MSVC target. Strip it (matches the
# tbox-feedstock win.sh).
sed -i 's/-fPIC//g' Makefile

# For a target that depends on a shared library the generator also emits an ELF
# rpath (-Wl,-rpath='$ORIGIN...'); this reaches cli_ldflags (cli -> xmake, sv)
# and xmake_shflags (xmake -> sv). rpath is meaningless on Windows and rejected
# by lld-link, and DLLs are instead resolved from the loader search path, so drop
# every -rpath directive.
sed -i "s|-Wl,-rpath=[^ ]*||g" Makefile

# Emit the import libraries deterministically. Linker directives are passed via
# response files (-Wl,@...) so their leading "/" is not mangled by the MSYS argv
# path conversion, and so /EXPORT: entries act as /OPT:REF GC roots.
#
#   * sv exports its API natively via __declspec(dllexport) (SV_COMPILE +
#     SV_BUILD_DYNAMIC_LINK + _MSC_VER, set in the patch); only pin the import
#     library name/location with /implib.
#   * xmake's core has no export annotations, so its DLL would export nothing and
#     produce no import library, breaking the cli link. The cli needs exactly one
#     entry point, xm_engine_run, so export that symbol and emit xmake.lib.
mkdir -p "${BUILD_DIR}"

SV_RSP="${BUILD_DIR}/sv_exports.rsp"
echo "/implib:${BUILD_DIR}/sv.lib" > "${SV_RSP}"
sed -i "s|^sv_shflags=|sv_shflags= -Wl,@${SV_RSP} |" Makefile

XMAKE_RSP="${BUILD_DIR}/xmake_exports.rsp"
{
    echo "/EXPORT:xm_engine_run"
    echo "/implib:${BUILD_DIR}/xmake.lib"
} > "${XMAKE_RSP}"
sed -i "s|^xmake_shflags=|xmake_shflags= -Wl,@${XMAKE_RSP} |" Makefile

make -j"${CPU_COUNT:-1}"
make install

# Verify sv exported its symbols and the import library was produced.
llvm-readobj --coff-exports "${BUILD_DIR}/sv.dll" \
    | sed -n 's/^[[:space:]]*Name: //p' | sort -u > "${BUILD_DIR}/sv.exports"
grep -qx 'semver_tryn' "${BUILD_DIR}/sv.exports" || {
    echo "ERROR: sv.dll does not export semver_tryn" >&2
    head -n 40 "${BUILD_DIR}/sv.exports" >&2
    exit 1
}
test -f "${BUILD_DIR}/sv.lib"

# Verify xmake exported its entry point and its import library was produced.
llvm-readobj --coff-exports "${BUILD_DIR}/xmake.dll" \
    | sed -n 's/^[[:space:]]*Name: //p' | grep -qx 'xm_engine_run' || {
    echo "ERROR: xmake.dll does not export xm_engine_run" >&2
    exit 1
}
test -f "${BUILD_DIR}/xmake.lib"

# xmake.exe is installed to share/xmake (kept out of bin so os.exec() does not
# pick up sibling executables). Its private DLLs must sit next to it so the
# loader finds them regardless of activation; the exe's own directory is the
# first entry in the Windows DLL search order.
install -Dm755 "${BUILD_DIR}/sv.dll"    "${PREFIX}/share/xmake/sv.dll"
install -Dm755 "${BUILD_DIR}/xmake.dll" "${PREFIX}/share/xmake/xmake.dll"

# Nothing is statically baked in: cli calls only xm_engine_run, so the installed
# xmake.exe imports xmake.dll directly, and xmake.dll in turn imports sv.dll (its
# only use of the third-party semver code). Verify that dependency chain from the
# PE import tables.
llvm-objdump -p "${PREFIX}/share/xmake/xmake.exe" 2>/dev/null \
    | grep -i 'DLL Name' > "${BUILD_DIR}/xmake.exe.imports" || true
grep -qi 'DLL Name: xmake.dll' "${BUILD_DIR}/xmake.exe.imports" || {
    echo "ERROR: xmake.exe does not import xmake.dll (not linked dynamically)" >&2
    cat "${BUILD_DIR}/xmake.exe.imports" >&2
    exit 1
}
llvm-objdump -p "${PREFIX}/share/xmake/xmake.dll" 2>/dev/null \
    | grep -i 'DLL Name' > "${BUILD_DIR}/xmake.dll.imports" || true
grep -qi 'DLL Name: sv.dll' "${BUILD_DIR}/xmake.dll.imports" || {
    echo "ERROR: xmake.dll does not import sv.dll (sv not linked dynamically)" >&2
    cat "${BUILD_DIR}/xmake.dll.imports" >&2
    exit 1
}

# Do not ship the import libraries (they are only needed to link the cli, and
# nothing downstream links against xmake).
rm -f "${PREFIX}/lib/sv.dll" "${PREFIX}/lib/xmake.dll" \
      "${PREFIX}/lib/sv.lib" "${PREFIX}/lib/xmake.lib"
