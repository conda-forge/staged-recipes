#!/usr/bin/env bash
# Runs upstream's tests against the installed isaaclab.
# One script for the recipe test and for local verification.
# It adapts to what the environment provides.
#   GPU (torch.cuda.is_available)  -> cuda cases run, otherwise they are dropped
#   omni.client importable         -> utils/test_assets.py runs
#   ovphysx importable             -> source/isaaclab_ov tests run
# omniverseclient and ovphysx are closed source, so they are never recipe dependencies.
# Extra arguments go to every pytest run.
# Usage: run_unit_tests.sh <IsaacLab source tree at the recipe version> [pytest args]
set -euo pipefail

src=${1:?path to an IsaacLab source tree at the recipe version}
shift
cd "${src}"

can_import() { python -c "import $1" >/dev/null 2>&1; }

gpu=0
if python -c "import torch; raise SystemExit(0 if torch.cuda.is_available() else 1)" >/dev/null 2>&1; then
  gpu=1
else
  # Hide the device so device-aware tests keep only their cpu cases.
  export CUDA_VISIBLE_DEVICES=""
fi

omni_client=0
can_import omni.client && omni_client=1

ovphysx=0
can_import ovphysx && ovphysx=1

echo "gpu=${gpu} omni_client=${omni_client} ovphysx=${ovphysx}"

run_pytest() { python -m pytest "$@"; }

# Shows which copy of isaaclab the tests import.
python -c "import isaaclab; print('isaaclab from', isaaclab.__file__)"

# Collect only the unit-marked files.
# Pointing pytest at test/ would import standalone scripts that parse args at import.
# The asset tests need omni.client, so they are left out when it is missing.
skip_assets='^$'
[ "${omni_client}" = 1 ] || skip_assets=utils/test_assets.py

# The grep -v drops the skipped asset tests, and matches nothing otherwise.
mapfile -t unit_files < <(grep -rl 'mark\.unit' source/isaaclab/test --include='*.py' | grep -v "${skip_assets}")

# Without files pytest would collect the whole current directory instead.
[ "${#unit_files[@]}" -gt 0 ] || { echo "no unit-marked test files found"; exit 1; }

# `-k "not cuda"` also catches older tests with cuda-parametrized ids.
k=""
[ "${gpu}" = 1 ] || k="not cuda"

# Run every pass even when an earlier one fails, and fail at the end.
rc=0
run_pytest -p no:cacheprovider "${unit_files[@]}" -m unit ${k:+-k "${k}"} "$@" || rc=$?

ov_dir=source/isaaclab_ov/test

if [ "${ovphysx}" = 0 ] || [ ! -d "${ov_dir}" ]; then
  exit "${rc}"
fi

# The isaaclab_ov tests are not unit-marked, and the integration ones launch whole simulations.
# The release tarball has Git LFS pointers instead of the binary test data.
# Skip the tests that load the articulation fixture then, instead of requiring git-lfs in the test environment.
# They fail with "not a valid usda layer" otherwise, so update this list with the version.
lfs_usda=${ov_dir}/assets/data/articulation_ordering_branching.usda

if head -c 100 "${lfs_usda}" 2>/dev/null | grep -q git-lfs; then
  echo "LFS pointer at ${lfs_usda}, skipping the tests that load it"
  lfs_skip=(
    reversed_joint_dynamics_use_public_joint_basis
    branching_fixture_physx_ordering_is_identity_on_ovphysx
    articulation_dynamics_reorder_body_rows_and_joint_axes
    cpu_only_property_writes_wait_for_pinned_host_staging
    material_body_and_environment_selection
    visual_material_environment_selection
    collider_offsets_preserve_unselected_state
  )

  lfs_expr=$(printf '%s or ' "${lfs_skip[@]}")
  k+="${k:+ and }not (${lfs_expr% or })"
fi

cache=$(mktemp -d)
trap 'rm -rf "${cache}"' EXIT

ov_args=("${ov_dir}" -m "not integration" -o "cache_dir=${cache}" ${k:+-k "${k}"})

if [ "${gpu}" = 0 ]; then
  run_pytest "${ov_args[@]}" "$@" || rc=$?
  exit "${rc}"
fi

# OvPhysxManager locks the device for the lifetime of the process, so cpu and cuda cases cannot share one.
# Run everything in a first process, where the first test takes its device.
# The cases for the other device fail there with the device lock error.
# Then rerun only those failures in a second process, which takes the other device.
# Real failures fail twice.
pass1=0
run_pytest "${ov_args[@]}" "$@" || pass1=$?
if [ "${pass1}" -gt 1 ]; then
  rc=$((rc | pass1))
elif [ "${pass1}" = 1 ]; then
  run_pytest "${ov_args[@]}" --last-failed --last-failed-no-failures none "$@" || rc=$?
fi
exit "${rc}"
