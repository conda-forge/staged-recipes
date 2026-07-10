#!/usr/bin/env bash
set -exo pipefail

export ESBUILD_BINARY_PATH="${BUILD_PREFIX}/bin/esbuild"
export PYO3_PYTHON="${PYTHON}"

# tree-sitter 0.25.10 needs glibc endian conversion macros on Linux.
if [[ "${target_platform}" == linux-* ]]; then
  export CFLAGS="${CFLAGS:-} -D_GNU_SOURCE"
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo_args=()
target_root="${CARGO_TARGET_DIR:-target}"
release_dir="${target_root}/release"

if [[ -n "${CARGO_BUILD_TARGET:-}" ]]; then
  cargo_args+=(--target "${CARGO_BUILD_TARGET}")
  release_dir="${target_root}/${CARGO_BUILD_TARGET}/release"
fi

cargo build --release --locked "${cargo_args[@]}" \
  -p patinae \
  -p raytracer-plugin \
  -p hello-plugin \
  -p ipc-plugin \
  -p python-plugin

mkdir -p "${PREFIX}/libexec/patinae/bin"
install -m 755 "${release_dir}/patinae" "${PREFIX}/libexec/patinae/bin/patinae"

mkdir -p "${PREFIX}/libexec/patinae/plugins"

shopt -s nullglob
plugins=( "${release_dir}"/lib*_plugin"${SHLIB_EXT}" )

if (( ${#plugins[@]} == 0 )); then
  echo "No plugin libraries found in ${release_dir}"
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
prefix=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
PATINAE_PLUGIN_DIR="${PATINAE_PLUGIN_DIR:-${prefix}/libexec/patinae/plugins}"
export PATINAE_PLUGIN_DIR
exec "${prefix}/libexec/patinae/bin/patinae" "$@"
EOF
chmod +x "${PREFIX}/bin/patinae"
