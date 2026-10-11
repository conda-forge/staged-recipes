#!/usr/bin/env bash
set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=symbols
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
export NPM_CONFIG_AUDIT=false
export NPM_CONFIG_FUND=false
export NPM_CONFIG_UPDATE_NOTIFIER=false
export npm_config_arch=x64
export NODE_OPTIONS="--max-old-space-size=6144"
# upstream build number, e.g. 2026.10.0.297 -> 297
export POSITRON_BUILD_NUMBER="${PKG_VERSION##*.}"
# node-gyp: use conda's python and compilers
export npm_config_python="${BUILD_PREFIX}/bin/python"
export CXXFLAGS="${CXXFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"
# postinstall builds some native modules with plain gcc/g++/cc/c++; point those at conda's toolchain
mkdir -p "${SRC_DIR}/_shims"
ln -sf "$(command -v "${CC}")" "${SRC_DIR}/_shims/gcc"
ln -sf "$(command -v "${CXX}")" "${SRC_DIR}/_shims/g++"
ln -sf "$(command -v "${CC}")" "${SRC_DIR}/_shims/cc"
ln -sf "$(command -v "${CXX}")" "${SRC_DIR}/_shims/c++"
export PATH="${SRC_DIR}/_shims:${PATH}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"

# The source tarballs are not git checkouts, but positron's install scripts query
# git for the ark/ai-lib submodules (version labels) and init them if .git is
# missing. Give each a minimal local repo so those calls succeed offline.
# The CI work dir sits inside the staged-recipes checkout; stop git from treating the
# source as part of that repo (otherwise `git apply` in positron-python silently skips patches).
export GIT_CEILING_DIRECTORIES="$(dirname "${SRC_DIR}")"
git_snapshot() {
  git -C "$1" init -q
  git -C "$1" add -A
  git -C "$1" -c user.name=conda-forge -c user.email=conda-forge@users.noreply.github.com \
    commit -q --no-verify -m "source snapshot"
}
git_snapshot extensions/positron-r/ark
git_snapshot ai-lib
# postinstall also runs `git add --renormalize` at the root
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

# The CI agents are short on disk: drop rust build trees and caches
rm -rf extensions/positron-r/ark/target/{debug,x86_64-*} _kallichore/target _pet/target "${CARGO_HOME:-$HOME/.cargo}/registry" "${CARGO_HOME:-$HOME/.cargo}/git"

# --- Vendored pure-python libraries for positron-python (patch 0002) ---
# Built from sdist where conda-forge lacks the pinned version; the rest come from the build env.
python -m pip install --no-deps --no-build-isolation --no-index --target "${SRC_DIR}/_pysrc" \
  ./_pysrc_src/cattrs ./_pysrc_src/pydantic
export CONDA_VENDOR_SCRIPT="${RECIPE_DIR}/copy_from_env.py"
export CONDA_VENDOR_PATHS="${SRC_DIR}/_pysrc:$(python -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')"
# requirements.txt pins typing-extensions 4.15.0 and the kernel requirements pin 4.10.0;
# only one version can be in the build env, so allow 4.15.0 for both
export CONDA_VENDOR_ALLOW_MISMATCH=typing-extensions
export CONDA_VENDOR_LICENSES="${SRC_DIR}/_vendored_licenses"

# compile native node modules instead of downloading prebuilt binaries
export npm_config_build_from_source=true

# --- Positron ---
export NPM_CONFIG_CACHE="${SRC_DIR}/.npm-cache"
# CI=1 makes postinstall skip syncing submodules against their remotes.
CI=1 npm ci --no-audit --no-fund
rm -rf "${NPM_CONFIG_CACHE}"
# desktop-only build (core-ci would also build the remote server variants, which exhausts CI memory)
npm run gulp vscode-linux-x64-min

# --- install ---
# free disk before packaging: the build trees are no longer needed
rm -rf node_modules build/node_modules remote/node_modules extensions/*/node_modules \
  out out-build out-vscode-min .build _bin
mkdir -p "${PREFIX}/lib" "${PREFIX}/bin"
# mv (same filesystem) instead of cp, to avoid duplicating ~1GB on the full CI disk
mv ../VSCode-linux-x64 "${PREFIX}/lib/positron"
ln -sf ../lib/positron/bin/positron "${PREFIX}/bin/positron"

# use conda-forge's ripgrep instead of the prebuilt rg downloaded by @vscode/ripgrep
rg_bundled="${PREFIX}/lib/positron/resources/app/node_modules.asar.unpacked/@vscode/ripgrep-universal/bin/linux-x64/rg"
if [[ -e "${rg_bundled}" ]]; then
  rm -f "${rg_bundled}"
  ln -s ../../../../../../../../../bin/rg "${rg_bundled}"
fi

# js-debug's VSIX ships Windows-only native helpers; they're unused on linux
find "${PREFIX}/lib/positron/resources/app/extensions" -name '*win32*.node' -delete

# desktop integration (menuinst), as in other conda-forge Electron apps
mkdir -p "${PREFIX}/Menu"
cp "${RECIPE_DIR}/positron.json" "${PREFIX}/Menu/positron.json"
cp "${PREFIX}/lib/positron/resources/app/resources/linux/positron.png" "${PREFIX}/Menu/positron.png"

# collect the license files of everything bundled in the app (npm packages, PDF.js, vendored python)
python "${RECIPE_DIR}/collect_licenses.py" "${PREFIX}/lib/positron/resources/app" "${SRC_DIR}/third-party-licenses"
