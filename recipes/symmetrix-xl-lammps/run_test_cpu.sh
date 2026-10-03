#!/usr/bin/env bash

set -euo pipefail

help_output=$(mktemp)
mpi_input=$(mktemp)
mpi_output=$(mktemp)
trap 'rm -f -- "$help_output" "$mpi_input" "$mpi_output"' EXIT

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

lmp_executable=$(command -v lmp-symmetrix)
linkage=$(ldd "${lmp_executable}")
if grep -q 'not found' <<<"${linkage}"; then
  exit 1
fi
for library in libmpi libopenblas libgomp; do
  grep -E "^[[:space:]]*${library}\\.so[^[:space:]]* => ${PREFIX}/(bin/\\.\\./)?lib/" \
    <<<"${linkage}"
done
if grep -E 'libcuda|libcudart|libnvrtc|libcublas' <<<"${linkage}"; then
  exit 1
fi

mpi_probe=$(command -v symmetrix-mpi-gpu-aware-probe)
test -x "${mpi_probe}"
mpirun --version
cat > "${mpi_input}" <<'EOF'
units lj
atom_style charge
boundary p p p

region box block 0 4 0 4 0 4
create_box 2 box
create_atoms 1 single 1.0 1.0 1.0
create_atoms 2 single 3.0 3.0 3.0

mass * 1.0
set type 1 charge 1.0
set type 2 charge -1.0
pair_style lj/cut/coul/long 2.5
pair_coeff * * 0.1 1.0
kspace_style pppm 1.0e-4

neighbor 0.3 bin
velocity all set 0.01 -0.01 0.02
fix integrate all nve
thermo 1
run 1
print "SYMMETRIX_MPI_PPPM_SMOKE_COMPLETE"
EOF
OMPI_ALLOW_RUN_AS_ROOT=1 OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
  mpirun -n 2 lmp-symmetrix -log none -in "${mpi_input}" > "${mpi_output}"
grep -q 'PPPM initialization' "${mpi_output}"
grep -q 'using double precision FFTW3' "${mpi_output}"
grep -q '^SYMMETRIX_MPI_PPPM_SMOKE_COMPLETE$' "${mpi_output}"
if grep -aFq "${SRC_DIR}" "${lmp_executable}"; then
  exit 1
fi
