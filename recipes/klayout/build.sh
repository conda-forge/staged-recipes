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

PY_MM=$($PYTHON -c "import sys; print('%d.%d' % sys.version_info[:2])")


mkdir -p "$PWD/cc_shim"
ln -sf "$CXX" "$PWD/cc_shim/g++"
ln -sf "$CXX" "$PWD/cc_shim/c++"
ln -sf "$CC" "$PWD/cc_shim/gcc"
ln -sf "$CC" "$PWD/cc_shim/cc"
export PATH="$PWD/cc_shim:$PATH"

./build.sh \
    -expert \
    -bin "$PREFIX/bin" \
    -qmake "$PREFIX/bin/qmake6" \
    -noruby \
    -without-qtbinding \
    -python "$PYTHON" \
    -pyinc "$($PYTHON -c "import sysconfig; print(sysconfig.get_paths()['include'])")" \
    -pylib "$PREFIX/lib/libpython${PY_MM}.so" \
    -libpng \
    -libcurl \
    -libexpat \
    -option "-j${CPU_COUNT:-2}"

mkdir -p "$SP_DIR"
cp -a "$PREFIX/bin/pymod/klayout" "$SP_DIR/klayout"
cp -a "$PREFIX/bin/pymod/pya" "$SP_DIR/pya"
rm -f "$PREFIX/bin"/*.a
