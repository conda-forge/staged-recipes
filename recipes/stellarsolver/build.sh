#!/usr/bin/env bash
set -euxo pipefail

# Expose the vasprintf declaration used by the bundled Astrometry.net C code.
if [[ "${target_platform}" == linux-* ]]; then
    export CFLAGS="${CFLAGS} -D_GNU_SOURCE"
fi

case "$1" in
    base)
        build_library=ON
        build_cli=ON
        build_gui=OFF
        ;;
    gui)
        build_library=OFF
        build_cli=OFF
        build_gui=ON
        ;;
    *)
        echo "Usage: $0 {base|gui}" >&2
        exit 2
        ;;
esac

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DUSE_QT5=ON \
    -DBUILD_LIBRARY="${build_library}" \
    -DBUILD_CLI="${build_cli}" \
    -DBUILD_TESTER="${build_gui}" \
    -DBUILD_BATCH_SOLVER="${build_gui}" \
    -DBUILD_DEMOS=OFF \
    -DBUILD_TESTS=OFF

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
