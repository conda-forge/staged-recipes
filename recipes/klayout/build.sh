#!/usr/bin/env bash
set -exo pipefail

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export CFLAGS="$CFLAGS -O2 -fPIC"
export CXXFLAGS="$CXXFLAGS -O2 -fPIC"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -Wl,-rpath,$PREFIX/bin"

PY_MM=$($PYTHON -c "import sys; print('%d.%d' % sys.version_info[:2])")

# linux-only: shim gcc/g++ names to the x86_64-conda-linux-gnu toolchain,
# because klayout's own build.sh invokes plain gcc/g++
mkdir -p "$PWD/cc_shim"
ln -sf "$(command -v x86_64-conda-linux-gnu-c++)" "$PWD/cc_shim/g++"
ln -sf "$(command -v x86_64-conda-linux-gnu-c++)" "$PWD/cc_shim/c++"
ln -sf "$(command -v x86_64-conda-linux-gnu-cc)" "$PWD/cc_shim/gcc"
ln -sf "$(command -v x86_64-conda-linux-gnu-cc)" "$PWD/cc_shim/cc"
export PATH="$PWD/cc_shim:$PATH"

./build.sh -expert -bin "$PREFIX/bin" -qmake "$PREFIX/bin/qmake6" -noruby -python "$PYTHON" -pyinc "$($PYTHON -c "import sysconfig; print(sysconfig.get_paths()['include'])")" -pylib "$PREFIX/lib/libpython${PY_MM}.so" -libpng -libcurl -libexpat -option "-j12"

mkdir -p "$SP_DIR"
cp -a "$PREFIX/bin/pymod/klayout" "$SP_DIR/klayout"
cp -a "$PREFIX/bin/pymod/pya" "$SP_DIR/pya"
rm -f "$PREFIX/bin"/*.a
