#!/usr/bin/env bash
set -euxo pipefail

cmake_bool() {
  case "${1:-}" in
    1|[Oo][Nn]|[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]) printf 'ON' ;;
    *) printf 'OFF' ;;
  esac
}

job_count() {
  local value="${1:-0}"
  local fallback="${CPU_COUNT:-1}"

  case "${value}" in
    ''|0) value="${fallback}" ;;
  esac

  positive_integer "job count" "${value}"
}

positive_integer() {
  local label="$1"
  local value="$2"

  case "${value}" in
    *[!0-9]*|'')
      printf 'Invalid %s: %s\n' "${label}" "${value}" >&2
      return 1
      ;;
  esac

  if [ "${value}" -lt 1 ]; then
    printf 'Invalid %s: %s\n' "${label}" "${value}" >&2
    return 1
  fi

  printf '%s' "${value}"
}

build_tests="$(cmake_bool "${nrgljubljana_build_tests:-OFF}")"
test_long="$(cmake_bool "${nrgljubljana_test_long:-OFF}")"
enable_mathematica="$(cmake_bool "${nrgljubljana_enable_mathematica:-OFF}")"
strict_floating_point="$(cmake_bool "${nrgljubljana_strict_floating_point:-OFF}")"
cmake_build_type="${nrgljubljana_cmake_build_type:-Release}"
build_jobs="$(job_count "${nrgljubljana_build_jobs:-0}")"
test_jobs="$(job_count "${nrgljubljana_test_jobs:-0}")"
test_timeout="$(positive_integer "test timeout" "${nrgljubljana_test_timeout:-7200}")"
test_regex="${nrgljubljana_test_regex:-}"
blas_impl_value="${blas_impl:-}"

if [ "${target_platform:-}" = "linux-aarch64" ] && [ "${blas_impl_value}" != "nvpl" ]; then
  export OPENBLAS_CORETYPE="${OPENBLAS_CORETYPE:-ARMV8}"
fi

cmake -S . -B build -G Ninja \
  ${CMAKE_ARGS:-} \
  -DCMAKE_BUILD_TYPE="${cmake_build_type}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_IGNORE_PREFIX_PATH="/opt/homebrew;/usr/local" \
  -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON \
  -DCMAKE_CXX_SCAN_FOR_MODULES=OFF \
  -DHDF5_ROOT="${PREFIX}" \
  -DNRGLJUBLJANA_USE_SYSTEM_DEPS=ON \
  -DNRGLJUBLJANA_ENABLE_MATHEMATICA="${enable_mathematica}" \
  -DNRGLJUBLJANA_INSTALL_NRGINIT=ON \
  -DNRGLJUBLJANA_STRICT_FLOATING_POINT="${strict_floating_point}" \
  -DBuild_Tests="${build_tests}" \
  -DTEST_LONG="${test_long}" \
  -DBuild_Documentation=OFF \
  -DMPI_C_COMPILER="${PREFIX}/bin/mpicc" \
  -DMPI_CXX_COMPILER="${PREFIX}/bin/mpicxx" \
  -DMPIEXEC_EXECUTABLE="${PREFIX}/bin/mpiexec"

cmake --build build --parallel "${build_jobs}"

if [ "${build_tests}" = "ON" ]; then
  export OMP_NUM_THREADS=1
  export MKL_NUM_THREADS=1
  export OPENBLAS_NUM_THREADS=1
  ctest_args=(--test-dir build --output-on-failure --parallel "${test_jobs}" --timeout "${test_timeout}" --no-tests=error)
  if [ -n "${test_regex}" ]; then
    ctest_args+=(-R "${test_regex}")
  fi
  ctest "${ctest_args[@]}"
fi

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
