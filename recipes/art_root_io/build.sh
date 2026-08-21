#!/bin/bash
# art_root_io: ROOT event I/O for the art framework (#9, the final product).
# Provides the Root{Input,Output} sources/modules, TFileService, and the ROOT
# dictionaries for art's data products. Same cetmodules non-UPS build pattern;
# art / canvas_root_io / ROOT and the sibling closure resolve from the host env.
set -euo pipefail

mkdir -p build
cd build

# _CheckClassVersion_ENABLED=FALSE: skip cetmodules' post-dictionary
# checkClassVersion step (runs `import ROOT`/PyROOT, which cannot initialize in
# the rattler-build sandbox). The rootcling dictionaries themselves build fine --
# only this PyROOT *validation* fails. Same fix as canvas_root_io (#7).
# See conda/potential_improvements.md (#8).
# CMAKE_CXX_STANDARD=20: the e28 stack is C++20, and conda-forge ROOT is cxx20.
cmake \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=20 \
  -DCMAKE_CXX_STANDARD_REQUIRED=ON \
  -DBUILD_TESTING=OFF \
  -DWANT_UPS:BOOL=OFF \
  -D_CheckClassVersion_ENABLED:BOOL=FALSE \
  "$SRC_DIR"

make -j"${CPU_COUNT:-1}" install

# NOTE: prefix-root doc pollution (README/LICENSE/INSTALL) is prevented at the
# source by patches/0002-no-install-pkgmeta.patch (cet_cmake_env(NO_INSTALL_PKGMETA)),
# so there is nothing to strip here. A bare `rm -f $PREFIX/README` would hit
# ROOT's $PREFIX/README *directory* (EISDIR) and abort under set -e.
