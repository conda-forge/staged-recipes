#!/bin/bash
# cetmodules is a pure CMake/Perl/Bash build-helper product -- project() declares
# LANGUAGES NONE, so there is nothing to compile. `make install` just stages the
# CMake Modules, the generated cetmodulesConfig.cmake and the helper scripts.
#
# Non-UPS mode is the default; WANT_UPS:BOOL=OFF is set explicitly so no UPS
# table/setup machinery is emitted into $PREFIX.
set -euo pipefail

cmake \
  ${CMAKE_ARGS} \
  -DWANT_UPS:BOOL=OFF \
  -S "${SRC_DIR}" \
  -B build

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

# cetmodules installs INSTALL/LICENSE/README as plain files at the PREFIX ROOT,
# polluting the environment root. This collides with other packages that use
# those paths as directories -- notably ROOT, which installs $PREFIX/README/
# (ReleaseNotes/...): a file-vs-directory clash (ENOTDIR) when both land in one
# env. Remove the stray prefix-root docs. See conda/potential_improvements.md (#7).
rm -f "$PREFIX/INSTALL" "$PREFIX/LICENSE" "$PREFIX/README"
