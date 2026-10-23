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
PY_LIB=$($PYTHON -c "import sysconfig, os; print(os.path.join(sysconfig.get_config_var('LIBDIR'), sysconfig.get_config_var('LDLIBRARY')))")

mkdir -p "$PWD/cc_shim"
cat << 'EOF' > "$PWD/cc_shim/g++"
#!/usr/bin/env bash
exec ${CXX:-g++} "$@"
EOF

cat << 'EOF' > "$PWD/cc_shim/c++"
#!/usr/bin/env bash
exec ${CXX:-g++} "$@"
EOF

cat << 'EOF' > "$PWD/cc_shim/gcc"
#!/usr/bin/env bash
exec ${CC:-gcc} "$@"
EOF

cat << 'EOF' > "$PWD/cc_shim/cc"
#!/usr/bin/env bash
exec ${CC:-gcc} "$@"
EOF

chmod +x "$PWD/cc_shim"/*
export PATH="$PWD/cc_shim:$PATH"

./build.sh \
    -expert \
    -bin "$PREFIX/bin" \
    -qmake "$PREFIX/bin/qmake6" \
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
