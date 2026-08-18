#!/usr/bin/env bash
set -euxo pipefail

if [ "${target_platform:-}" = "linux-aarch64" ] && [ "${blas_impl:-}" != "nvpl" ]; then
  export OPENBLAS_CORETYPE="${OPENBLAS_CORETYPE:-ARMV8}"
fi

cmake -S . -B build -G Ninja \
  ${CMAKE_ARGS:-} \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_CXX_SCAN_FOR_MODULES=OFF \
  -DHDF5_ROOT="${PREFIX}" \
  -DNRGLJUBLJANA_USE_SYSTEM_DEPS=ON \
  -DNRGLJUBLJANA_ENABLE_MATHEMATICA=OFF \
  -DBuild_Tests=OFF \
  -DMPI_C_COMPILER="${PREFIX}/bin/mpicc" \
  -DMPI_CXX_COMPILER="${PREFIX}/bin/mpicxx" \
  -DMPIEXEC_EXECUTABLE="${PREFIX}/bin/mpiexec"

cmake --build build --parallel "${CPU_COUNT:-1}"

cmake --install build

mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"

cat > "${PREFIX}/etc/conda/activate.d/nrgljubljana.sh" <<'ACTIVATE_EOF'
export NRGLJUBLJANA_ROOT="${CONDA_PREFIX}"

if [ "${NRGLJUBLJANA_CONDA_PATH_BACKUP+x}" != "x" ]; then
  export NRGLJUBLJANA_CONDA_PATH_BACKUP="${PATH:-}"
fi

case ":${PATH:-}:" in
  *":${CONDA_PREFIX}/nrginit:"*) ;;
  *) export PATH="${CONDA_PREFIX}/nrginit${PATH:+:${PATH}}" ;;
esac
ACTIVATE_EOF

cat > "${PREFIX}/etc/conda/deactivate.d/nrgljubljana.sh" <<'DEACTIVATE_EOF'
if [ "${NRGLJUBLJANA_CONDA_PATH_BACKUP+x}" = "x" ]; then
  export PATH="${NRGLJUBLJANA_CONDA_PATH_BACKUP}"
  unset NRGLJUBLJANA_CONDA_PATH_BACKUP
fi

unset NRGLJUBLJANA_ROOT
DEACTIVATE_EOF
