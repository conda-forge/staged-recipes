export CFLAGS="${CFLAGS:-} -ffile-prefix-map=$SRC_DIR=."
export CXXFLAGS="${CXXFLAGS:-} -ffile-prefix-map=$SRC_DIR=."
if [[ $target_platform == osx-* ]]; then
    # Match the uncontracted expressions used on Linux and Windows.
    export CFLAGS="$CFLAGS -fno-fast-math -ffp-contract=off"
    export CXXFLAGS="$CXXFLAGS -fno-fast-math -ffp-contract=off -Wno-reserved-user-defined-literal"
fi
IPOPT_PREFIX="$SRC_DIR/ipopt-prefix"
export PKG_CONFIG_PATH="$IPOPT_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
