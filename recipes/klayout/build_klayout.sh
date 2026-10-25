#!/usr/bin/env bash
set -exo pipefail
# -expert passes QMAKE_CC/QMAKE_CXX as ordinary command-line assignments, which
# qmake applies only after default_pre.prf -> toolchain.prf has already probed
# the mkspec's hardcoded `g++`. `-early` applies them before that probe; the
# trailing `-before` restores the default for build.sh's own assignments.
# build.sh expands $QMAKE unquoted, so these extra words reach qmake.
# qmake's -early flag applies settings before that compiler check
#
# build.sh installs everything (executables, libklayout_*.so, db_plugins/,
# lay_plugins/, pymod/) into a single directory, so keep that directory out of
# $PREFIX/bin and fix up the python package and executables afterwards.
KLAYOUT_DIR="$PREFIX/lib/klayout"
./build.sh \
    -expert \
    -prefix "$KLAYOUT_DIR" \
    -qmake "$PREFIX/bin/qmake6 -early QMAKE_CC=$CC QMAKE_CXX=$CXX -before" \
    -noruby \
    -without-qtbinding \
    -python "$PYTHON" \
    -pyinc "$PREFIX/include/python${PY_VER}" \
    -pylib "$PREFIX/lib/libpython${PY_VER}${SHLIB_EXT}" \
    -libpng \
    -libcurl \
    -libexpat \
    -option "-j${CPU_COUNT:-2}"

mkdir -p "$SP_DIR"
mv "$KLAYOUT_DIR/pymod/klayout" "$KLAYOUT_DIR/pymod/pya" "$SP_DIR/"
rmdir "$KLAYOUT_DIR/pymod"

# klayout locates its plugins from the resolved path of the executable, so
# symlinks in $PREFIX/bin work.
mkdir -p "$PREFIX/bin"
for exe in $(find "$KLAYOUT_DIR" -maxdepth 1 -type f -perm -u+x ! -name '*.so*'); do
    ln -s "../lib/klayout/$(basename "$exe")" "$PREFIX/bin/$(basename "$exe")"
done
