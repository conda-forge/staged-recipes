#!/usr/bin/env bash
set -euo pipefail

export OMP_NUM_THREADS=2
export OMPI_ALLOW_RUN_AS_ROOT=1
export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

if [[ "$(uname)" == "Linux" ]]; then
  version="$(ompi_info --version | awk '/Open MPI/ { print $NF; exit }')"
  major="${version#v}"
  major="${major%%.*}"
  if [[ "${major}" -ge 5 ]]; then
    export OMPI_MCA_btl="self,sm,tcp"
  else
    export OMPI_MCA_btl="self,vader,tcp"
    export OMPI_MCA_btl_vader_single_copy_mechanism="none"
  fi
fi

openmx="${PREFIX}/bin/openmx"
mpiexec="$(command -v mpiexec)"
data_path="${PREFIX}/share/openmx/DFT_DATA19"
example_dir="${PREFIX}/share/openmx/examples/work"
reference="${example_dir}/input_example/Methane.out"
data_path_example="${example_dir}/Benzene_RCP.dat"

test -x "${openmx}"
test -x "${mpiexec}"
test -d "${data_path}"
test -r "${example_dir}/Methane.dat"
test -r "${reference}"
test -r "${data_path_example}"

awk -v p="${data_path}" '
  $1 == "DATA.PATH" && $2 == p { ok = 1 }
  END { exit !ok }
' "${data_path_example}"

if [[ "$(uname)" == "Darwin" ]]; then
  otool -L "${openmx}" | grep -q "libomp"
  if otool -L "${openmx}" | grep -q "libgomp"; then
    echo "Unexpected libgomp linkage" >&2
    exit 1
  fi
fi

cp "${example_dir}/Methane.dat" Methane.dat

mpiexec_args=(-n 2 --oversubscribe)

if ! "${mpiexec}" "${mpiexec_args[@]}" "${openmx}" Methane.dat -nt 2 > openmx.out 2>&1; then
  cat openmx.out >&2
  exit 1
fi

grep -q "The calculation was normally finished" openmx.out
grep -q "Total Computational Time" met.out

expected_utot="$(awk '/^[[:space:]]*Utot\./ { print $2; exit }' "${reference}")"
actual_utot="$(awk '/^[[:space:]]*Utot\./ { print $2; exit }' met.out)"

if [[ -z "${expected_utot}" || -z "${actual_utot}" ]]; then
  echo "Could not read Utot from reference or test output" >&2
  exit 1
fi

awk -v expected="${expected_utot}" -v actual="${actual_utot}" 'BEGIN {
  delta = actual - expected
  if (delta < 0) {
    delta = -delta
  }
  exit !(delta <= 1e-6)
}'
