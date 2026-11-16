#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause
#
# Builds the OpenMM plugin against libcupo-dev and installs its Python package,
# nv_openmm_plugin, into site-packages with pip, as the wheel is built: the
# Python modules, the SWIG module, and the two plugin libraries in
# nv_openmm_plugin/lib/. libcupo.so stays in $PREFIX/lib, where the libcupo
# package has it.
set -euxo pipefail

# The source tree's copy of cupo's headers, and its libraries if a tree has them:
# the build must take both from libcupo-dev.
rm -rf "$SRC_DIR/include/cupo" "$SRC_DIR/build"

PLUGIN="$SRC_DIR/plugins/openmm"
# The CUDA architectures are libcupo's, not the CUDA compiler's CUDAARCHS: the
# plugin's kernels run beside libcupo's, so a GPU that libcupo has no code for
# cannot run the plugin either.
cmake -S "$PLUGIN" -B "$SRC_DIR/build-conda" ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CUDA_ARCHITECTURES="75;80;86;89;90;100;103;120" \
    -DCupoRuntime_DIR="$PREFIX/lib/cmake/CupoRuntime" \
    -DOPENMM_INCLUDE_DIR="$PREFIX/include" \
    -DOPENMM_CORE_LIBRARY="$PREFIX/lib/libOpenMM.so" \
    -DOPENMM_CUDA_LIBRARY="$PREFIX/lib/plugins/libOpenMMCUDA.so" \
    -DOPENMM_EXTRA_INCLUDE_DIRS="$PREFIX/include/openmm/cuda" \
    -DSWIG_EXECUTABLE="$BUILD_PREFIX/bin/swig" \
    -DPython3_EXECUTABLE="$PYTHON"
cmake --build "$SRC_DIR/build-conda" -j"${CPU_COUNT}"

# The package's payload, staged in the tree where setup.py looks for it, as the
# plugin's run_build stages it for the wheel, less libcupo.so. With
# NV_OPENMM_PLUGIN_CONDA=1, setup.py (setup-conda.patch) takes no libcupo.so, no
# libcupo notices and no runtime_build.json, which the libcupo package has, and
# declares no requirements: conda provides openmm and the CUDA libraries.
PKG="$PLUGIN/python/nv_openmm_plugin"
mkdir -p "$PKG/lib" "$PKG/notices"
cp "$PLUGIN/cpp/swig/_nvplugin.so" "$PLUGIN/cpp/swig/nvplugin.py" "$PKG/"
cp "$SRC_DIR/build-conda/cpp/libOpenMMNvidia.so" \
   "$SRC_DIR/build-conda/cpp/platforms/cuda/libOpenMMNvidiaCUDA.so" "$PKG/lib/"
# The licensing overview, full texts and notices, where NOTICE says a package
# has them. THIRD-PARTY.txt may be a symlink in a source checkout.
cp -L "$SRC_DIR/NOTICE" "$SRC_DIR/THIRD-PARTY.txt" "$SRC_DIR/LICENSE" \
    "$SRC_DIR/LICENSE-apache.txt" "$SRC_DIR/LICENSE-cupo.txt" "$PKG/notices/"
cd "$PLUGIN"
NV_OPENMM_PLUGIN_CONDA=1 "$PYTHON" -m pip install . --no-deps --no-build-isolation -vv

# check-glibc runs readelf, and without one it checks nothing and passes.
command -v readelf
check-glibc "$SP_DIR"/nv_openmm_plugin/*.so "$SP_DIR"/nv_openmm_plugin/lib/*.so
