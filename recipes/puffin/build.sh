#!/usr/bin/env bash

set -euxo pipefail

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" && "${mpi}" == "openmpi" ]]; then
  # for openmpi cross compilation
  export OPAL_PREFIX="${PREFIX}"
fi

cmake ${CMAKE_ARGS} \
  -B build \
  -S . \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_PARALLEL:BOOL=ON \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

# Upstream installs Python utility directories into bin/ and example inputs
# into $PREFIX/examples; relocate both to share/puffin/.
mkdir -p "${PREFIX}/share/puffin"
mv "${PREFIX}/examples" "${PREFIX}/share/puffin/examples"
for util in post pyPlotting setup visit-scripts; do
  mv "${PREFIX}/bin/${util}" "${PREFIX}/share/puffin/${util}"
done

rm -f "${PREFIX}/lib/libpuffin_mpi.a"
