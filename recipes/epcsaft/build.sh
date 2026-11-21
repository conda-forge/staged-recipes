#!/usr/bin/env bash
set -euo pipefail
JOBS=${CPU_COUNT:-1}
export CFLAGS="${CFLAGS:-} -ffile-prefix-map=$SRC_DIR=."
export CXXFLAGS="${CXXFLAGS:-} -ffile-prefix-map=$SRC_DIR=."
engine_verbose=
if [[ $target_platform == osx-* ]]; then
    # Round every ordinary expression as written, as on Linux and Windows: arm64 would otherwise fuse a*b + c.
    export CFLAGS="$CFLAGS -fno-fast-math -ffp-contract=off" CXXFLAGS="$CXXFLAGS -fno-fast-math -ffp-contract=off"
    # Ipopt 3.11.9 writes "..."IPOPT_VERSION, an error under clang's C++11 rules; the Windows build passes the same flag.
    export CXXFLAGS="$CXXFLAGS -Wno-reserved-user-defined-literal"
    # The 2007 Ipopt scripts predate current Darwin hosts; the compile commands are printed for the contraction gate.
    find "$SRC_DIR/ipopt-source" \( -name config.guess -o -name config.sub \) -exec sh -c 'cp "$BUILD_PREFIX/share/gnuconfig/$(basename "$1")" "$1"' _ {} \;
    engine_verbose=--config-settings=compile-args=-v
fi
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
if [[ $target_platform == osx-* ]]; then
    ipopt_library=$(basename "$(otool -D "$IPOPT_PREFIX/lib/libipopt.dylib" | tail -n 1)")
    install_name_tool -id "@rpath/$ipopt_library" "$IPOPT_PREFIX/lib/$ipopt_library"
fi
cd "$SRC_DIR"
cp -a engine/build/subprojects/packagefiles/cppad/. engine/build/subprojects/CppAD-20250000.3/
export PKG_CONFIG_PATH="$IPOPT_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
"$PYTHON" -m pip install ./engine -vv --no-deps --no-build-isolation \
    --config-settings=setup-args=--wrap-mode=nodownload \
    --config-settings=compile-args=-j"$JOBS" ${engine_verbose:+"$engine_verbose"} \
    ${EPCSAFT_BUILD_DIR:+--config-settings=build-dir="$EPCSAFT_BUILD_DIR"}
mkdir -p "$SP_DIR/epcsaft/data/packets"
for packet in feos-gross-sadowski-2001 feos-gross-sadowski-2002; do
    mkdir -p "$SP_DIR/epcsaft/data/packets/$packet"
    cp -a "$SRC_DIR/data/packets/$packet/1" "$SP_DIR/epcsaft/data/packets/$packet/"
done
if [[ $target_platform == osx-* ]]; then
    install -m755 "$IPOPT_PREFIX/lib/$ipopt_library" "$SP_DIR/epcsaft/"
    # The search path Linux sets with patchelf, then an ad hoc signature: dyld refuses an edited arm64 image unsigned.
    for library in "$SP_DIR/epcsaft"/*.so "$SP_DIR/epcsaft"/*.dylib; do
        for path in $(otool -l "$library" | awk '$1 == "cmd" && $2 == "LC_RPATH" {getline; getline; print $2}'); do
            install_name_tool -delete_rpath "$path" "$library"
        done
        install_name_tool -add_rpath @loader_path -add_rpath @loader_path/../../.. "$library"
        codesign -f -s - "$library"
    done
else
    install -m755 "$IPOPT_PREFIX/lib/libipopt.so.1.9.9" "$SP_DIR/epcsaft/"
    ln -s libipopt.so.1.9.9 "$SP_DIR/epcsaft/libipopt.so.1"
    for library in "$SP_DIR/epcsaft"/*.so "$SP_DIR/epcsaft/libipopt.so.1.9.9"; do
        patchelf --set-rpath '$ORIGIN:$ORIGIN/../../..' "$library"
    done
fi
"$PYTHON" "$RECIPE_DIR/licenses.py"
