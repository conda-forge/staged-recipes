#!/usr/bin/env bash
set -exo pipefail

# Configure tool paths and PyO3 for the conda build environment.
export ESBUILD_BINARY_PATH="${BUILD_PREFIX}/bin/esbuild"
export PYO3_PYTHON="${PYTHON}"

# tree-sitter 0.25.10 needs glibc endian conversion macros on Linux.
if [[ "${target_platform}" == linux-* ]]; then
  export CFLAGS="${CFLAGS:-} -D_GNU_SOURCE"
fi

# Generate Rust license metadata for all shipped Rust workspaces.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
pushd python > /dev/null
cargo-bundle-licenses --format yaml --output ../THIRDPARTY-python.yml
popd > /dev/null
pushd web > /dev/null
cargo-bundle-licenses --format yaml --output ../THIRDPARTY-web.yml
popd > /dev/null

# Resolve Cargo target and release directories.
cargo_args=()
target_root="${CARGO_TARGET_DIR:-target}"
release_dir="${target_root}/release"

if [[ -n "${CARGO_BUILD_TARGET:-}" ]]; then
  cargo_args+=(--target "${CARGO_BUILD_TARGET}")
  release_dir="${target_root}/${CARGO_BUILD_TARGET}/release"
fi

# Build the native desktop binary and native plugins with auditable metadata.
cargo auditable build --release --locked "${cargo_args[@]}" \
  -p patinae \
  -p raytracer-plugin \
  -p hello-plugin \
  -p ipc-plugin \
  -p python-plugin

# Install the native desktop binary under libexec.
mkdir -p "${PREFIX}/libexec/patinae/bin"
install -m 755 "${release_dir}/patinae" "${PREFIX}/libexec/patinae/bin/patinae"

# Install native plugin libraries under libexec.
mkdir -p "${PREFIX}/libexec/patinae/plugins"

shopt -s nullglob
plugins=( "${release_dir}"/lib*_plugin"${SHLIB_EXT}" )

if (( ${#plugins[@]} == 0 )); then
  echo "No plugin libraries found in ${release_dir}"
  find "${target_root}" -type f -name "*_plugin${SHLIB_EXT}" -print
  exit 1
fi

install -m 755 "${plugins[@]}" "${PREFIX}/libexec/patinae/plugins/"

# Prepare web dependencies and JavaScript license metadata.
pushd web

#
# NOTE: web/package.json currently has no production dependencies, so this
# branch is expected to stay false and keep an empty file. Keep the guard for
# forward-compatibility if upstream later adds runtime web dependencies.
if jq -e '((.dependencies // {}) + (.optionalDependencies // {})) | length > 0' package.json > /dev/null; then
  pnpm install --prod --ignore-scripts
  pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
else
  echo "No production npm dependencies; creating empty third-party-licenses.txt"
  : > third-party-licenses.txt
fi

# Install full web build dependencies without running package scripts.
rm -rf node_modules
pnpm import
pnpm install --ignore-scripts --frozen-lockfile

# Build the WebAssembly viewer without inheriting native Rust linker flags.
# NOTE: wasm-pack is intentionally not used here. wasm-pack always attempts
# to download a matching wasm-bindgen binary at build time, which fails in
# the network-isolated conda-forge build environment. wasm-bindgen-cli is
# already installed as a build dependency, so cargo and wasm-bindgen are
# invoked directly instead.
(
  unset RUSTFLAGS
  unset CARGO_ENCODED_RUSTFLAGS
  unset CARGO_BUILD_RUSTFLAGS
  unset CARGO_BUILD_TARGET
  unset LDFLAGS
  unset CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_RUSTFLAGS
  unset CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER

  wasm_target_root="${CARGO_TARGET_DIR:-target}"

  cargo build --release --locked --target wasm32-unknown-unknown -p patinae-web

  mkdir -p pkg
  wasm-bindgen \
    --target web \
    --out-dir pkg \
    --no-typescript \
    "${wasm_target_root}/wasm32-unknown-unknown/release/patinae_web.wasm"
)

# Bundle the web viewer assets with Vite.
pnpm exec vite build
popd

# Copy web viewer assets into the Python widget package.
mkdir -p python/patinae/widget/static
cp web/dist/patinae-viewer.js python/patinae/widget/static/
cp web/dist/patinae_web_bg.wasm python/patinae/widget/static/
cp web/dist/patinae_web-*.js python/patinae/widget/static/patinae_web_glue.js

# Build and install the Python extension wheel.
maturin build --release \
  --manifest-path python/Cargo.toml \
  --interpreter "${PYTHON}" \
  --out wheels
"${PYTHON}" -m pip install --no-deps -vv wheels/patinae-*.whl

# Keep the Python console entry point under a non-conflicting name.
if [[ -f "${PREFIX}/bin/patinae" ]]; then
  mv "${PREFIX}/bin/patinae" "${PREFIX}/bin/patinae-cli"
else
  echo "Expected pip-installed console script 'patinae' entry point not found." >&2
  exit 1
fi

# Install the user-facing desktop wrapper as `patinae`.
cat > "${PREFIX}/bin/patinae" <<'EOF'
#!/bin/sh
script_dir=$(dirname "$(command -v "$0" 2>/dev/null || printf '%s\n' "$0")")
here=$(CDPATH= cd "${script_dir}" && pwd)
PATINAE_PLUGIN_DIR="${PATINAE_PLUGIN_DIR:-${here}/../libexec/patinae/plugins}"
export PATINAE_PLUGIN_DIR
exec "${here}/../libexec/patinae/bin/patinae" "$@"
EOF
chmod +x "${PREFIX}/bin/patinae"

# Register a menuinst desktop shortcut so the installed icon launches the
# `patinae` wrapper (and thus picks up PATINAE_PLUGIN_DIR) rather than the
# raw libexec binary.
mkdir -p "${PREFIX}/Menu"
sed -e "s/__PKG_VERSION__/${PKG_VERSION}/g" "${RECIPE_DIR}/menu.json" > "${PREFIX}/Menu/patinae_menu.json"
cp "${SRC_DIR}/images/patinae.png" "${PREFIX}/Menu/patinae.png"
cp "${SRC_DIR}/images/patinae.ico" "${PREFIX}/Menu/patinae.ico"
