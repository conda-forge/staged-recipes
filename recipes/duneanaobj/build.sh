#!/usr/bin/env bash
set -euo pipefail

# Build via the upstream cetmodules path. The 0001-cetmodules-no-ups.patch makes
# that path trigger on `NOT SKIP_CET` (no UPS needed). cetmodules then drives
# build_dictionary + the Proxy/Flat subdirs.
#
# srproxy (a build tool) pulls a full ROOT into $BUILD_PREFIX, so there are two
# ROOTs in the build. Pin the host ROOT as the single one used for dictionary
# generation AND its class-version check (both ROOTSYS and PATH), so the check
# doesn't resolve base-class PCMs against the wrong prefix.
export ROOTSYS="${PREFIX}"
export PATH="${PREFIX}/bin:${PATH}"

# The Proxy/Flat CMakeLists run gen_srproxy and read these env vars.
# (gen_srproxy itself derives castxml's compiler from $CXX/$CC — patched in the
# srproxy recipe — so no compiler shim is needed here.)
export ROOT_INC="${PREFIX}/include"
export SRPROXY_INC="${PREFIX}/include"

cmake ${CMAKE_ARGS} -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -S "${SRC_DIR}" \
    -B build

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
