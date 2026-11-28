#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause
#
# Installs the cupo tarball the conda way. The tarball keeps its libraries in
# build/, where a build of the repository has them; here they go to lib/:
#   build/libcupo.so.<VERSION>         -> lib/libcupo.so.<VERSION>  (libcupo)
#   build/libcupo.so.<ABI>, build/libcupo.so, its links, to lib/ as links (libcupo)
#   include/cupo/                      -> include/cupo/             (libcupo-dev)
#   build/cmake/CupoRuntime/           -> lib/cmake/CupoRuntime/    (libcupo-dev)
#   share/cmake/CupoConvolution/       -> share/cmake/CupoConvolution/
#   build/runtime_build.json          -> share/cupo/runtime_build.json
#   build/ltoir/<variant>/cupo_math.cu.o -> lib/cupo/ltoir/<variant>/ (LTO-IR objects)
# The CMake packages name build/ for the library and for each other, so those
# paths are rewritten to lib/.
set -euxo pipefail

# The tarball's own record of the library and its CUDA (runtime_build.json):
# the library must be the one it describes, built with CUDA 13.4, the CUDA of
# the tarball's name, which the recipe's run requirements name.
grep -q "\"library_sha256\": \"$(sha256sum build/libcupo.so | cut -d' ' -f1)\"" build/runtime_build.json
grep -q "\"cuda_min\": \"13.4\"" build/runtime_build.json

mkdir -p "$PREFIX/lib" "$PREFIX/include" "$PREFIX/lib/cmake" "$PREFIX/share/cmake" \
    "$PREFIX/share/cupo" "$PREFIX/lib/cupo/ltoir"
# The library and its links, as the tarball has them: libcupo.so ->
# libcupo.so.<ABI> -> libcupo.so.<VERSION>. The library's SONAME is
# libcupo.so.<ABI>, which is the name the loader looks for, and the CMake
# package names libcupo.so.<VERSION>.
cp -a build/libcupo.so build/libcupo.so.*[0-9] "$PREFIX/lib/"
cp -r include/cupo "$PREFIX/include/"
cp -r build/cmake/CupoRuntime "$PREFIX/lib/cmake/"
cp build/runtime_build.json "$PREFIX/share/cupo/"
for variant in standard fast_math; do
    mkdir -p "$PREFIX/lib/cupo/ltoir/$variant"
    cp "build/ltoir/$variant/cupo_math.cu.o" "$PREFIX/lib/cupo/ltoir/$variant/"
done
sed -i 's#${_IMPORT_PREFIX}/build/#${_IMPORT_PREFIX}/lib/#g' \
    "$PREFIX"/lib/cmake/CupoRuntime/CupoRuntimeTargets-*.cmake
if [ -d share/cmake/CupoConvolution ]; then
    cp -r share/cmake/CupoConvolution "$PREFIX/share/cmake/"
    sed -i 's#${PACKAGE_PREFIX_DIR}/build/cmake/CupoRuntime#${PACKAGE_PREFIX_DIR}/lib/cmake/CupoRuntime#' \
        "$PREFIX/share/cmake/CupoConvolution/CupoConvolutionConfig.cmake"
fi
# No path to build/ is left in the CMake packages.
if grep -rn '/build/' "$PREFIX/lib/cmake/CupoRuntime" "$PREFIX/share/cmake"; then
    echo "the CMake packages above still name build/" >&2
    exit 1
fi

# check-glibc runs readelf, and without one it checks nothing and passes. It also
# skips symbolic links, so it is given the library under all its names: the
# versioned file is the one it checks.
command -v readelf
check-glibc "$PREFIX"/lib/libcupo.so.*
