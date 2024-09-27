#!/usr/bin/env bash
set -eux

mkdir bdsim-build
cd bdsim-build

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      "${SRC_DIR}"

make "-j${CPU_COUNT}" ${VERBOSE_CM:-}
make install "-j${CPU_COUNT}"

# Remove the geant4.(c)sh scripts and replace with a dummy version
rm "${PREFIX}/bin/bdsim.sh"
cp "${RECIPE_DIR}/bdsim.sh" "${PREFIX}/bin/bdsim.sh"
chmod +x "${PREFIX}/bin/bdsim.sh"
