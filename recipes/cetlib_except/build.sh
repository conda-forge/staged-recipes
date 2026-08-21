#!/bin/bash
# cetlib_except: small C++ exception library, first real consumer of cetmodules.
# This build.sh is the template for the rest of the art suite -- a plain CMake
# project that find_package(cetmodules)es and uses its macros.
set -euo pipefail

mkdir -p build
cd build

# CMAKE_PREFIX_PATH=$PREFIX so find_package(cetmodules) + find_package(Catch2)
# resolve against the host env (where the local-channel cetmodules + conda-forge
# catch2 are installed). BUILD_TESTING=OFF: don't build/run the unit tests
# (catch2 is still required at configure time for the always-built
# cetlib_except::Catch2Matchers interface target).
#
# CMAKE_CXX_STANDARD=20: this stack (UPS qualifier e28) is C++20 -- the headers
# use concept/requires, so a C++17 build hard-fails. Matches conda-forge's cxx20
# ROOT used by the downstream ROOT products.
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

# Like cetmodules, cetlib_except installs INSTALL/LICENSE/README as plain files
# at the PREFIX ROOT. $PREFIX/README (a file) collides with ROOT's $PREFIX/README/
# directory (ReleaseNotes/...) -- a file-vs-directory clash that fails host_env
# linking with ENOTDIR ("Not a directory") the moment both land in one env, i.e.
# at canvas_root_io (#7), the first ROOT-dependent product. Strip the stray
# prefix-root docs. (license_file: LICENSE in recipe.yaml copies LICENSE from the
# SOURCE into info/licenses, so this $PREFIX strip does not affect it.)
# See conda/potential_improvements.md (#7).
rm -f "$PREFIX/INSTALL" "$PREFIX/LICENSE" "$PREFIX/README"
