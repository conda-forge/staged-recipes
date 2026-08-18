#!/usr/bin/env bash
set -euo pipefail

# lfric-env is a metapackage: there is nothing of its own to test except the two
# things it promises -- (1) the activation contract has been applied, and (2) the
# closure it pulls in really is a working LFRic toolchain.
#
# This is the packaged form of ickc/lfric-conda's scripts/test-env.sh, which runs
# the same checks against an environment built from envs/lfric-env.yaml.
#
# Every assertion goes through check(), which runs its command inside an `if` so
# that `set -e` does not abort on the first failure: one CI run should report
# every broken thing, not just the earliest.

fail=0
check() {  # check <label> <command...>
  local label="$1"; shift
  if "$@"; then
    printf '  ok    %s\n' "$label"
  else
    printf '  FAIL  %s\n' "$label"
    fail=1
  fi
}
# Whole-word membership in a space-separated flag string.
has_flag() { case " $1 " in *" $2 "*) return 0 ;; *) return 1 ;; esac; }
# MPICH_CXX may legitimately be either a bare command name (the conventional
# spelling of GXX, resolved by mpich through PATH) or an absolute path, so
# resolve it the way mpich will rather than stat-ing it as a file.
is_cmd()   { [ -n "${1:-}" ] && command -v "$1" >/dev/null 2>&1; }

echo "== 1. activation contract =="
# rattler-build activates the test environment, which sources the package's own
# etc/conda/activate.d/zzz-lfric-env.sh -- so all of this must already be set in
# this shell, without the test doing anything.
#
# The prefix is spelled $CONDA_PREFIX for a user who ran `conda activate` and
# $PREFIX inside a package test; activate.sh resolves either, so the expected
# value here has to allow both.
prefix="${CONDA_PREFIX:-${PREFIX:-}}"
check "prefix resolved (${prefix:-<none>})"                 test -n "${prefix}"
check "LFRIC_ENV_ACTIVE == prefix (${LFRIC_ENV_ACTIVE:-<unset>})" \
      test "${LFRIC_ENV_ACTIVE:-}" = "${prefix}"
check "FC == mpif90 (${FC:-<unset>})"       test "${FC:-}" = "mpif90"
check "LDMPI == mpif90 (${LDMPI:-<unset>})" test "${LDMPI:-}" = "mpif90"
check "CXX == mpic++ (${CXX:-<unset>})"     test "${CXX:-}" = "mpic++"
check "SHUMLIB_ROOT == prefix"              test "${SHUMLIB_ROOT:-}" = "${prefix}"
check "HDF5_USE_FILE_LOCKING == FALSE"      test "${HDF5_USE_FILE_LOCKING:-}" = "FALSE"
check "FPP set (${FPP:-<unset>})"           test -n "${FPP:-}"
check "LFRIC_TARGET_PLATFORM set (${LFRIC_TARGET_PLATFORM:-<unset>})" \
      test -n "${LFRIC_TARGET_PLATFORM:-}"
check 'FFLAGS carries -I<prefix>/include' \
      has_flag "${FFLAGS:-}" "-I${prefix}/include"
check 'LDFLAGS carries -L<prefix>/lib' \
      has_flag "${LDFLAGS:-}" "-L${prefix}/lib"

# MPICH_CXX only applies where the C++ toolchain is GNU (linux). On macOS
# conda-forge's C/C++ compiler is clang, there is no g++ to point at, and
# activate.sh deliberately leaves it unset -- so this is a linux-only assertion.
if [ "$(uname -s)" = "Linux" ]; then
  check "MPICH_CXX resolves to a g++ driver (${MPICH_CXX:-<unset>})" \
        is_cmd "${MPICH_CXX:-}"
fi

echo "== 2. tools on PATH =="
# What LFRic's build system and its Rose/Cylc workflows shell out to BY NAME.
# rose_picker keeps its underscore (the conda package is hyphenated, the console
# script is not); xios_server.exe is the I/O server LFRic launches at run time.
#
# pFUnit's funitproc is deliberately NOT here: pFUnit installs into a versioned
# subdirectory ($PREFIX/PFUNIT-<x.y>/bin), which is not on PATH by design -- its
# consumers find it through the CMake package config. Checked in section 4.
for tool in mpif90 mpic++ mpiexec cmake make pkg-config \
            psyclone fab rose_picker rose cylc \
            xios_server.exe; do
  check "$tool" command -v "$tool"
done

echo "== 3. Fortran module ABI =="
# The check the environment exists for -- see test_lfric_env.f90. FFLAGS is a
# flag STRING and must word-split, hence the deliberate lack of quoting.
# shellcheck disable=SC2086
if mpif90 -fsyntax-only ${FFLAGS:-} test_lfric_env.f90; then
  printf '  ok    use mpi / netcdf / xios / yaxt / shumlib compiles with the environment gfortran\n'
else
  printf '  FAIL  module ABI check did not compile\n'
  fail=1
fi

echo "== 4. libraries that are linked rather than USEd =="
# libxios is the static archive lfric_core links as -lxios; the PFUNIT-<x.y>
# subdir is the unit-test tier's CMake package.
check "lib/libxios.a" test -e "${prefix}/lib/libxios.a"
check "PFUNIT-*/cmake/PFUNITConfig.cmake" \
      bash -c 'ls "$0"/PFUNIT-*/cmake/PFUNITConfig.cmake >/dev/null 2>&1' "${prefix}"

if [ "$fail" -ne 0 ]; then
  echo "LFRIC_ENV_TEST_FAILED" >&2
  exit 1
fi
echo "LFRIC_ENV_OK"
