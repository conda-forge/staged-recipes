#!/usr/bin/env bash
set -euo pipefail
JOBS=${CPU_COUNT:-1}
export CFLAGS="${CFLAGS:-} -ffile-prefix-map=$SRC_DIR=."
export CXXFLAGS="${CXXFLAGS:-} -ffile-prefix-map=$SRC_DIR=."
IPOPT_PREFIX="$SRC_DIR/ipopt-prefix"
mkdir -p "$SRC_DIR/ipopt-build"
cd "$SRC_DIR/ipopt-build"
CFLAGS="${CFLAGS:-} -std=gnu11" \
CXXFLAGS="${CXXFLAGS:-} -std=gnu++11 -DIPOPT_BUILD" \
CPPFLAGS="${CPPFLAGS:-} -I$PREFIX/include" \
LDFLAGS="${LDFLAGS:-} -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib" \
"$SRC_DIR/ipopt-source/configure" \
    --prefix="$IPOPT_PREFIX" --disable-static --enable-dependency-linking \
    --disable-linear-solver-loader --without-hsl --without-asl \
    --without-pardiso --without-wsmp \
    --with-blas=-lblas --with-lapack=-llapack \
    --with-mumps-incdir="$PREFIX/include/mumps_seq" \
    --with-mumps-lib="$(pkg-config --libs dmumps_seq)"
make -j"$JOBS"
make install
cd "$SRC_DIR"
cp -a engine/build/subprojects/packagefiles/cppad/. engine/build/subprojects/CppAD-20250000.3/
export PKG_CONFIG_PATH="$IPOPT_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
"$PYTHON" -m pip install ./engine -vv --no-deps --no-build-isolation \
    --config-settings=setup-args=--wrap-mode=nodownload \
    --config-settings=compile-args=-j"$JOBS"
install -m755 "$IPOPT_PREFIX/lib/libipopt.so.1.9.9" "$SP_DIR/epcsaft/"
ln -s libipopt.so.1.9.9 "$SP_DIR/epcsaft/libipopt.so.1"
for library in "$SP_DIR/epcsaft"/*.so "$SP_DIR/epcsaft/libipopt.so.1.9.9"; do
    patchelf --set-rpath '$ORIGIN:$ORIGIN/../../..' "$library"
done
"$PYTHON" "$RECIPE_DIR/licenses.py"
