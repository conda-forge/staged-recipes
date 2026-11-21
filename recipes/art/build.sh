#!/bin/bash
# art: the FNAL event-processing framework executable + libraries (#8). Same
# cetmodules non-UPS build pattern as the rest of the suite; find_package resolves
# the full sibling closure (canvas/hep_concurrency/messagefacility/fhiclcpp/
# cetlib(_except)) plus CLHEP/Range-v3/TBB/Boost from the host env.
set -euo pipefail

mkdir -p build
cd build

# CMAKE_CXX_STANDARD=20: the e28 stack is C++20 (headers use concept/requires).
cmake \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=20 \
  -DCMAKE_CXX_STANDARD_REQUIRED=ON \
  -DBUILD_TESTING=OFF \
  -DWANT_UPS:BOOL=OFF \
  "$SRC_DIR"

make -j"${CPU_COUNT:-1}" install

# Strip stray prefix-root docs: $PREFIX/README (file) collides with ROOT's
# $PREFIX/README/ directory at host_env link/package time (ENOTDIR) once art is
# co-installed with art_root_io/ROOT. See conda/potential_improvements.md (#7)
# and the check-prefix-collisions skill.
rm -f "$PREFIX/INSTALL" "$PREFIX/LICENSE" "$PREFIX/README"
