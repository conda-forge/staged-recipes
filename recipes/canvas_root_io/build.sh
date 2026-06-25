#!/bin/bash
# canvas_root_io: ROOT I/O + dictionaries for canvas (first ROOT-dependent
# product). Dictionaries are generated via art_dictionary() -> cetmodules
# build_dictionary -> rootcling. Same cetmodules build pattern; ROOT and the
# sibling closure resolve from the host env.
set -euo pipefail

mkdir -p build
cd build

# _CheckClassVersion_ENABLED=FALSE: skip cetmodules' post-dictionary
# checkClassVersion step. That step runs `import ROOT` (PyROOT/cppyy) to verify
# ClassDef checksums, but PyROOT's interpreter cannot initialize in the
# rattler-build sandbox ("cppyy.gbl has no attribute 'gSystem'" / no interpreter
# info for TFunction). The dictionaries themselves (rootcling .cxx + .pcm) build
# fine -- only this PyROOT *validation* fails -- so we disable it. cetmodules
# normally force-enables it because conda ROOT reports the pyroot feature.
# See conda/potential_improvements.md (#8).
cmake \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTING=OFF \
  -DWANT_UPS:BOOL=OFF \
  -D_CheckClassVersion_ENABLED:BOOL=FALSE \
  "$SRC_DIR"

make -j"${CPU_COUNT:-1}" install

# Strip stray prefix-root docs the product itself installs. Guard with [ -f ]:
# ROOT is a host dep here, so $PREFIX/README is ROOT's *directory* -- a plain
# `rm -f $PREFIX/README` would hit EISDIR ("Is a directory") and abort under
# set -e. Only remove regular FILES (this product's own pollution), never the
# dependency's directory. See conda/potential_improvements.md (#7) and the
# check-prefix-collisions skill.
#for f in INSTALL LICENSE README; do
#  if [ -f "$PREFIX/$f" ]; then rm -f "$PREFIX/$f"; fi   # if/fi returns 0 even when absent (a bare `[ -f ] && rm` would exit 1 under set -e)
#done
