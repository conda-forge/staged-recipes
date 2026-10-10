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
# postinstall builds build/ natives with plain CC=gcc / CXX=g++; point those at conda's toolchain
mkdir -p "${SRC_DIR}/_shims"
ln -sf "$(command -v "${CC}")" "${SRC_DIR}/_shims/gcc"
ln -sf "$(command -v "${CXX}")" "${SRC_DIR}/_shims/g++"
export PATH="${SRC_DIR}/_shims:${PATH}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"

# The source tarballs are not git checkouts, but positron's install scripts query
# git for the ark/ai-lib submodules (version labels) and init them if .git is
# missing. Give each a minimal local repo so those calls succeed offline.
git_snapshot() {
  git -C "$1" init -q
  git -C "$1" add -A
  git -C "$1" -c user.name=conda-forge -c user.email=conda-forge@users.noreply.github.com \
    commit -q --no-verify -m "source snapshot"
}
git_snapshot extensions/positron-r/ark
git_snapshot ai-lib
git_snapshot .

# --- Rust components, built from source instead of downloading prebuilds ---

# Ark (R kernel): install-kernel.ts picks up a local build at ark/target/release/ark
pushd extensions/positron-r/ark
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY-ark.yml"
cargo install --bins --no-track --locked --root "${SRC_DIR}/_bin" --path crates/ark
popd
# conda's rust activation sets a target triple, so place the binary where install-kernel.ts looks
mkdir -p extensions/positron-r/ark/target/release
cp _bin/bin/ark extensions/positron-r/ark/target/release/ark

# Kallichore (kernel supervisor)
pushd _kallichore
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY-kallichore.yml"
cargo install --bins --no-track --locked --root "${SRC_DIR}/_bin" --path crates/kcserver
popd
mkdir -p extensions/positron-supervisor/resources/kallichore
cp _bin/bin/kcserver extensions/positron-supervisor/resources/kallichore/
printf '%s' "${KALLICHORE_VERSION}" > extensions/positron-supervisor/resources/kallichore/VERSION

# Python Environment Tools
pushd _pet
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY-pet.yml"
cargo install --bins --no-track --locked --root "${SRC_DIR}/_bin" --path crates/pet
popd
mkdir -p extensions/positron-python/python-env-tools extensions/positron-python/resources/pet
cp _bin/bin/pet extensions/positron-python/python-env-tools/
printf '%s' "${PET_VERSION}" > extensions/positron-python/resources/pet/VERSION

# --- Positron ---
# CI=1 makes postinstall skip syncing submodules against their remotes
CI=1 npm ci --no-audit --no-fund
npm run gulp core-ci
npm run gulp vscode-linux-x64-min-ci

# --- install ---
mkdir -p "${PREFIX}/lib/positron" "${PREFIX}/bin"
cp -a ../VSCode-linux-x64/. "${PREFIX}/lib/positron/"
ln -sf ../lib/positron/bin/positron "${PREFIX}/bin/positron"
