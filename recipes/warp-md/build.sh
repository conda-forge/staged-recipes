#!/usr/bin/env bash
set -euxo pipefail

# ── Remove .cargo/config.toml that hardcodes system paths ──────────────
rm -f .cargo/config.toml

# ── Third-party license bundling (conda-forge requirement for Rust) ────
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yaml

# ── Determine maturin feature flags ───────────────────────────────────
FEATURES="extension-module"

if [[ "${cuda_compiler_version:-None}" != "None" ]]; then
    FEATURES="extension-module,cuda"

    # Point build at conda-forge CUDA toolkit
    export CUDA_HOME="${PREFIX}"
    export CUDA_PATH="${PREFIX}"
fi

# ── HDF5: --no-default-features disables vendored static build. ──────
# The hdf5-metno crate will find conda's HDF5 via HDF5_DIR / pkg-config.
export HDF5_DIR="${PREFIX}"

# ── chemfiles: let pkg-config find the conda-forge chemfiles C lib ─────
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
export CHEMFILES_DIR="${PREFIX}"
export CMAKE_POLICY_VERSION_MINIMUM=3.5
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1

# ── Build the wheel ───────────────────────────────────────────────────
maturin build \
    --release \
    --strip \
    --interpreter "${PYTHON}" \
    --no-default-features \
    --features "${FEATURES}" \
    --out dist

# ── Install ───────────────────────────────────────────────────────────
"${PYTHON}" -m pip install dist/warp_md-*.whl \
    --no-deps --no-build-isolation -vv
