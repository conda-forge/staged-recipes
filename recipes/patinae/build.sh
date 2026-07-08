#!/usr/bin/env bash
set -exo pipefail

export ESBUILD_BINARY_PATH="${BUILD_PREFIX}/bin/esbuild"
export PYO3_PYTHON="${PYTHON}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --root "${PREFIX}/libexec/patinae" --path patinae
rm -f "${PREFIX}/libexec/patinae/.crates.toml" "${PREFIX}/libexec/patinae/.crates2.json"

cargo_args=()
target_root="${CARGO_TARGET_DIR:-target}"
plugin_release_dir="${target_root}/release"

if [[ -n "${CARGO_BUILD_TARGET:-}" ]]; then
  cargo_args+=(--target "${CARGO_BUILD_TARGET}")
  plugin_release_dir="${target_root}/${CARGO_BUILD_TARGET}/release"
fi

cargo build --release --locked --lib "${cargo_args[@]}" \
  -p raytracer-plugin \
  -p hello-plugin \
  -p ipc-plugin \
  -p python-plugin

mkdir -p "${PREFIX}/libexec/patinae/plugins"

shopt -s nullglob
plugins=( "${plugin_release_dir}"/lib*_plugin"${SHLIB_EXT}" )

if (( ${#plugins[@]} == 0 )); then
  echo "No plugin libraries found in ${plugin_release_dir}"
  find "${target_root}" -type f -name "*_plugin${SHLIB_EXT}" -print
  exit 1
fi

install -m 755 "${plugins[@]}" "${PREFIX}/libexec/patinae/plugins/"

pushd web

if jq -e '((.dependencies // {}) + (.optionalDependencies // {})) | length > 0' package.json > /dev/null; then
  pnpm install --prod --ignore-scripts
  pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
else
  echo "No production npm dependencies; creating empty third-party-licenses.txt"
  : > third-party-licenses.txt
fi

rm -rf node_modules
pnpm install --ignore-scripts --no-frozen-lockfile

# wasm32 build must not inherit conda host linker flags.
(
  unset RUSTFLAGS
  unset CARGO_ENCODED_RUSTFLAGS
  unset CARGO_BUILD_RUSTFLAGS
  unset CARGO_BUILD_TARGET
  unset LDFLAGS
  unset CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_RUSTFLAGS
  unset CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER
  "${BUILD_PREFIX}/bin/wasm-pack" build --target web --out-dir pkg --no-opt
)

pnpm exec vite build
popd

mkdir -p python/patinae/widget/static
cp web/dist/patinae-viewer.js python/patinae/widget/static/
cp web/dist/patinae_web_bg.wasm python/patinae/widget/static/
cp web/dist/patinae_web-*.js python/patinae/widget/static/patinae_web_glue.js

maturin build --release \
    --manifest-path python/Cargo.toml \
    --interpreter "${PYTHON}" \
    --out wheels
"${PYTHON}" -m pip install --no-deps -vv wheels/patinae-*.whl

rm -f "${PREFIX}/bin/patinae"
cat > "${PREFIX}/bin/patinae" <<'EOF'
#!/bin/sh
PATINAE_PLUGIN_DIR="${PATINAE_PLUGIN_DIR:-${CONDA_PREFIX}/libexec/patinae/plugins}"
export PATINAE_PLUGIN_DIR
exec "${CONDA_PREFIX}/libexec/patinae/bin/patinae" "$@"
EOF
chmod +x "${PREFIX}/bin/patinae"
