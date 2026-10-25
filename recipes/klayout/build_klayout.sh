#!/usr/bin/env bash
set -exo pipefail

if command -v mold >/dev/null 2>&1; then
    export CXXFLAGS="$CXXFLAGS -fuse-ld=mold"
    export LDFLAGS="$LDFLAGS -fuse-ld=mold"
fi

# -expert passes QMAKE_CC/QMAKE_CXX as ordinary command-line assignments, which
# qmake applies only after default_pre.prf -> toolchain.prf has already probed
# the mkspec's hardcoded `g++`. `-early` applies them before that probe; the
# trailing `-before` restores the default for build.sh's own assignments.
# build.sh expands $QMAKE unquoted, so these extra words reach qmake.
# qmake's -early flag applies settings before that compiler check
./build.sh \
    -expert \
    -bin "$PREFIX/bin" \
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
if [ -d "$PREFIX/bin/pymod/klayout" ]; then
    cp -a "$PREFIX/bin/pymod/klayout" "$SP_DIR/klayout"
fi
if [ -d "$PREFIX/bin/pymod/pya" ]; then
    cp -a "$PREFIX/bin/pymod/pya" "$SP_DIR/pya"
fi
