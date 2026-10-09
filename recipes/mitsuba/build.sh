#!/usr/bin/env bash

set -euxo pipefail

# Each enabled renderer variant instantiates a large C++ template surface.
# Keep peak memory bounded on high-core-count builders.
build_jobs=$((CPU_COUNT > 8 ? 8 : CPU_COUNT))
export CMAKE_BUILD_PARALLEL_LEVEL="${build_jobs}"
export CMAKE_GENERATOR="Ninja"

# Temporary workaround for the raw-pointer scatter patch in the conda-forge
# Dr.Jit 1.5.0 build: its forwarding-reference overload rejects Mitsuba's
# explicit-template lvalue calls. Use the pristine headers from the pinned
# Dr.Jit submodule while continuing to link against conda-forge's runtime.
# Remove this after https://github.com/mitsuba-renderer/drjit/pull/518 is
# released and the corresponding conda-forge Dr.Jit patch is retired.
export CPATH="${SRC_DIR}/ext/drjit/include${CPATH:+:${CPATH}}"

variants="scalar_rgb,scalar_spectral,scalar_spectral_polarized,llvm_ad_rgb,llvm_ad_mono,llvm_ad_mono_polarized,llvm_ad_spectral,llvm_ad_spectral_polarized"

# Linux x86-64 explicitly selects the CUDA 12.9 Dr.Jit flavor. The other
# enabled platforms use the CPU flavor and therefore omit CUDA variants.
if [[ "${target_platform:-}" == "linux-64" ]]; then
    variants+=",cuda_ad_rgb,cuda_ad_mono,cuda_ad_mono_polarized,cuda_ad_spectral,cuda_ad_spectral_polarized"
fi

export CMAKE_ARGS="${CMAKE_ARGS:-} -DMI_DEFAULT_VARIANTS=${variants}"

python -m pip install . -vv --no-deps --no-build-isolation
