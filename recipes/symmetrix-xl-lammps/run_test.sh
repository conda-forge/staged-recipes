#!/usr/bin/env bash

set -euo pipefail

help_output=$(mktemp)
driver_stub_directory=$(mktemp -d)
trap 'rm -f -- "$help_output"; rm -rf -- "$driver_stub_directory"' EXIT

driver_stub=$(find "${PREFIX}" \( -type f -o -type l \) \
  -path '*/stubs/libcuda.so' -print -quit)
test -n "${driver_stub}"
ln -s "${driver_stub}" "${driver_stub_directory}/libcuda.so.1"
export LD_LIBRARY_PATH="${driver_stub_directory}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

lmp-symmetrix -help > "${help_output}"
grep -q 'symmetrix/mace' "${help_output}"
grep -q 'symmetrix/timing' "${help_output}"

installed_packages=$(awk '
  /^Installed packages:/ { capture = 1; next }
  capture && NF { seen = 1; print; next }
  capture && seen && !NF { exit }
' "${help_output}")
for package in \
  ASPHERE BODY BROWNIAN CLASS2 COLLOID CORESHELL DIPOLE ELECTRODE \
  EXTRA-COMPUTE EXTRA-DUMP EXTRA-FIX EXTRA-MOLECULE EXTRA-PAIR FEP \
  GRANULAR KOKKOS KSPACE MANYBODY MC MEAM MISC ML-SNAP MOLECULE \
  OPENMP OPT PERI PHONON PLUGIN REAXFF REPLICA RIGID SHOCK SRD; do
  grep -qw -- "${package}" <<<"${installed_packages}"
done
if grep -qw -- 'COLVARS' <<<"${installed_packages}"; then
  exit 1
fi
if grep -qw -- 'ML-PACE' <<<"${installed_packages}"; then
  exit 1
fi

ldd "${PREFIX}/bin/lmp-symmetrix" | grep -q 'libfftw3'
ldd "${PREFIX}/bin/lmp-symmetrix" | grep -q 'libcufft'

lmp_executable=$(command -v lmp-symmetrix)
linkage=$(ldd "${lmp_executable}")
if grep -q 'not found' <<<"${linkage}"; then
  exit 1
fi
for library in libmpi libopenblas libgomp libcudart libcublas libcufft; do
  grep -E "^[[:space:]]*${library}\\.so[^[:space:]]* => ${PREFIX}/(bin/\\.\\./)?lib/" \
    <<<"${linkage}"
done

mpi_probe=$(command -v symmetrix-mpi-gpu-aware-probe)
test -x "${mpi_probe}"
mpirun --version
if grep -aFq "${SRC_DIR}" "${lmp_executable}"; then
  exit 1
fi
