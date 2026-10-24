#!/usr/bin/env bash
set -exo pipefail

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"

export CFLAGS="$CFLAGS -O2 -fPIC -g0"
export CXXFLAGS="$CXXFLAGS -O2 -fPIC -g0"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -Wl,-rpath,$PREFIX/bin"

if command -v mold >/dev/null 2>&1; then
    export CXXFLAGS="$CXXFLAGS -fuse-ld=mold"
    export LDFLAGS="$LDFLAGS -fuse-ld=mold"
fi

PY_INC=$($PYTHON -c "import sysconfig; print(sysconfig.get_path('include'))")
PY_LIB=$($PYTHON - <<'EOF'
import os
import sysconfig

libdir = sysconfig.get_config_var("LIBDIR")
candidates = []
for key in ("LDLIBRARY", "INSTSONAME"):
    name = sysconfig.get_config_var(key)
    if name:
        candidates.append(os.path.join(libdir, name))
ldlibrary = sysconfig.get_config_var("LDLIBRARY") or ""
if ldlibrary.endswith(".a"):
    candidates.append(os.path.join(libdir, ldlibrary[:-2] + ".so"))
for path in candidates:
    if os.path.isfile(path):
        print(path)
        break
else:
    raise SystemExit(f"error: no usable libpython found in {libdir}: tried {candidates}")
EOF
)

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
    -pyinc "$PY_INC" \
    -pylib "$PY_LIB" \
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
rm -f "$PREFIX/bin"/*.a
