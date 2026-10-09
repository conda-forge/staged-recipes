#!/usr/bin/env bash
set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=symbols
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
export NPM_CONFIG_AUDIT=false
export NPM_CONFIG_FUND=false
export NPM_CONFIG_UPDATE_NOTIFIER=false
export NODE_OPTIONS="--max-old-space-size=8192"
# upstream build number, e.g. 2026.10.0.297 -> 297
export POSITRON_BUILD_NUMBER="${PKG_VERSION##*.}"
# node-gyp: use conda's python and compilers
export npm_config_python="${BUILD_PREFIX}/bin/python"
export CXXFLAGS="${CXXFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"

# --- Rust components, built from source instead of downloading prebuilds ---

# Ark (R kernel): install-kernel.ts picks up a local build at ark/target/release/ark
pushd extensions/positron-r/ark
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY-ark.yml"
cargo build --release --locked -p ark
popd

# Kallichore (kernel supervisor)
pushd _kallichore
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY-kallichore.yml"
cargo build --release --locked -p kcserver
popd
mkdir -p extensions/positron-supervisor/resources/kallichore
cp _kallichore/target/release/kcserver extensions/positron-supervisor/resources/kallichore/
printf '%s' "${KALLICHORE_VERSION}" > extensions/positron-supervisor/resources/kallichore/VERSION

# Python Environment Tools
pushd _pet
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY-pet.yml"
cargo build --release --locked -p pet
popd
mkdir -p extensions/positron-python/python-env-tools extensions/positron-python/resources/pet
cp _pet/target/release/pet extensions/positron-python/python-env-tools/
printf '%s' "${PET_VERSION}" > extensions/positron-python/resources/pet/VERSION

# --- Positron ---
npm ci --no-audit --no-fund
npm run gulp core-ci
npm run gulp vscode-linux-x64-min-ci

# --- install ---
mkdir -p "${PREFIX}/lib/positron" "${PREFIX}/bin"
cp -a ../VSCode-linux-x64/. "${PREFIX}/lib/positron/"
ln -sf ../lib/positron/bin/positron "${PREFIX}/bin/positron"
