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
mkdir -p licenses
"$PYTHON" - <<'PY'
from importlib import metadata
from pathlib import Path
import nanobind
dist = metadata.distribution("nanobind")
license_path = next(p for p in dist.files if str(p).endswith("/licenses/LICENSE"))
Path("licenses/nanobind-LICENSE").write_text(dist.locate_file(license_path).read_text())
header = Path(nanobind.__file__).parent / "ext/robin_map/include/tsl/robin_map.h"
Path("licenses/robin-map-LICENSE").write_text(header.read_text().split("*/", 1)[0] + "*/\n")
PY
