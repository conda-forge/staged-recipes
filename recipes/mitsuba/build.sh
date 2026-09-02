#!/usr/bin/env bash

set -euxo pipefail

# Each enabled renderer variant instantiates a large C++ template surface.
# Keep peak memory bounded on high-core-count builders.
build_jobs=$((CPU_COUNT > 8 ? 8 : CPU_COUNT))
export CMAKE_BUILD_PARALLEL_LEVEL="${build_jobs}"
export CMAKE_GENERATOR="Ninja"

# The conda-forge Dr.Jit 1.5.0 package carries a raw-pointer scatter patch
# whose forwarding-reference overload rejects Mitsuba's explicit-template
# lvalue calls. Prefer the pristine 1.5.0 headers from Mitsuba's pinned Dr.Jit
# submodule while continuing to link against the conda-forge Dr.Jit runtime.
export CPATH="${SRC_DIR}/ext/drjit/include${CPATH:+:${CPATH}}"

variants="scalar_rgb,scalar_spectral,scalar_spectral_polarized,llvm_ad_rgb,llvm_ad_mono,llvm_ad_mono_polarized,llvm_ad_spectral,llvm_ad_spectral_polarized,cuda_ad_rgb,cuda_ad_mono,cuda_ad_mono_polarized,cuda_ad_spectral,cuda_ad_spectral_polarized,metal_ad_rgb,metal_ad_mono,metal_ad_mono_polarized,metal_ad_spectral,metal_ad_spectral_polarized"
export CMAKE_ARGS="${CMAKE_ARGS:-} -DMI_DEFAULT_VARIANTS=${variants}"

python -m pip install . -vv --no-deps --no-build-isolation
