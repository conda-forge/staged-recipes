#!/bin/bash
set -euxo pipefail

if [[ "${target_platform}" != "win-64" ]]; then
    cp "${BUILD_PREFIX}/share/gnuconfig/config.guess" .
    cp "${BUILD_PREFIX}/share/gnuconfig/config.sub" .
fi

cd "${SRC_DIR}"

# Set up LDFLAGS appropriately for each platform
case "$(uname)" in
    Linux)
        export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -lrt"
        ;;
    Darwin)
        export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
        ;;
    *)
        export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
        ;;
esac

# Model files are now extracted directly to src/ directory
# (no need to copy since target_directory was removed from recipe.yaml)

autoreconf --install --symlink --force --verbose
./configure --prefix="${PREFIX}" --enable-x86-rtcd

if [[ "${target_platform}" == "win-64" ]]; then
    patch_libtool
    # Set REMOVE_LIB_PREFIX for Windows builds to handle library naming
    export REMOVE_LIB_PREFIX=1
fi

make -j"${CPU_COUNT:-1}"
make install
