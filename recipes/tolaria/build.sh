#!/bin/bash
set -euxo pipefail

echo "=== Build environment ==="
node --version
pnpm --version
cargo --version
rustc --version
echo "Target platform: ${target_platform:-?}"

# Vite + React 19 frontend build needs more heap than the Node default.
export NODE_OPTIONS="--max-old-space-size=6144"

echo "=== Installing JS workspace dependencies ==="
pnpm install --frozen-lockfile --strict-peer-dependencies=false

echo "=== Generating Rust third-party license inventory ==="
( cd src-tauri && cargo-bundle-licenses --format yaml --output ../THIRDPARTY-RUST.yml )

echo "=== Generating npm third-party license disclaimer ==="
pnpm licenses list --prod --long > THIRDPARTY-NPM.txt

[[ -f LICENSE ]]
[[ -f THIRDPARTY-RUST.yml ]]
[[ -f THIRDPARTY-NPM.txt ]]

# Tauri config override: skip updater artifact generation (we ship the .app or
# raw binary directly; the updater needs an upstream-managed signing key we
# don't have access to).
TAURI_OVERRIDE='{"bundle":{"createUpdaterArtifacts":false}}'

# conda-forge's rust compiler activation sets CARGO_BUILD_TARGET to the
# cross-compile triple (e.g. aarch64-apple-darwin), so cargo outputs to
# target/<triple>/release/ instead of target/release/. Native builds leave it
# unset, so fall back to rustc's host triple (== the cargo target on a native
# build). NEVER use `rustc -vV` 'host:' as the cross target: that's the
# platform rustc runs on, not the one it emits code for.
RUST_TARGET="${CARGO_BUILD_TARGET:-$(rustc -vV | awk '/^host:/ {print $2}')}"

BUNDLE_ID="club.refactoring.tolaria"

case "${target_platform}" in
  osx-arm64)
    echo "=== macOS arm64 build (.app bundle) ==="
    # --bundles app -> the full Tolaria.app (needed for Tauri's macOS resource
    # resolution via Info.plist + Contents/Resources); skips .dmg + updater.
    # tauri.conf bundle.resources stages mcp-server + agent-docs into the .app.
    pnpm tauri build --bundles app --config "${TAURI_OVERRIDE}"

    APP_SRC="src-tauri/target/${RUST_TARGET}/release/bundle/macos/Tolaria.app"
    [[ -d "${APP_SRC}" ]] || APP_SRC="src-tauri/target/release/bundle/macos/Tolaria.app"
    [[ -d "${APP_SRC}" ]]

    mkdir -p "${PREFIX}/lib"
    cp -R "${APP_SRC}" "${PREFIX}/lib/Tolaria.app"

    # Apple Silicon refuses to load unsigned arm64 binaries. Tauri emits an
    # unsigned bundle with no signingIdentity configured — ad-hoc sign so the
    # conda-installed app actually launches.
    codesign --force --deep --sign - "${PREFIX}/lib/Tolaria.app"
    codesign --verify "${PREFIX}/lib/Tolaria.app"

    # Launcher: menuinst + `tolaria` on PATH exec into the bundled binary so
    # Tauri's Info.plist + Resources resolution works.
    mkdir -p "${PREFIX}/bin"
    cat > "${PREFIX}/bin/tolaria" << 'EOF'
#!/bin/bash
exec "$(dirname "$0")/../lib/Tolaria.app/Contents/MacOS/Tolaria" "$@"
EOF
    chmod +x "${PREFIX}/bin/tolaria"

    mkdir -p "${PREFIX}/Menu"
    cp src-tauri/icons/icon.icns "${PREFIX}/Menu/tolaria.icns"
    ;;

  linux-64)
    echo "=== Linux x86_64 build (raw binary) ==="
    # --no-bundle: produce only target/release/tolaria, skip the .deb/.AppImage
    # bundlers (they'd just be repackaged out of conda's prefix). Mirrors
    # conda-forge/nebi-feedstock.
    pnpm tauri build --no-bundle --config "${TAURI_OVERRIDE}"

    BIN_SRC="src-tauri/target/${RUST_TARGET}/release/tolaria"
    [[ -x "${BIN_SRC}" ]] || BIN_SRC="src-tauri/target/release/tolaria"
    [[ -x "${BIN_SRC}" ]]

    mkdir -p "${PREFIX}/bin"
    cp "${BIN_SRC}" "${PREFIX}/bin/tolaria"

    # Stage the bundled resources at Tauri's Linux runtime resource location:
    # tauri::path::resource_dir() falls back to <exe>/../lib/<bundle_id>/.
    # beforeBuildCommand (pnpm bundle-mcp / pnpm agent-docs) populates
    # src-tauri/resources/{mcp-server,agent-docs} before the cargo build runs.
    mkdir -p "${PREFIX}/lib/${BUNDLE_ID}"
    cp -R src-tauri/resources/mcp-server "${PREFIX}/lib/${BUNDLE_ID}/"
    cp -R src-tauri/resources/agent-docs "${PREFIX}/lib/${BUNDLE_ID}/"

    mkdir -p "${PREFIX}/Menu"
    cp src-tauri/icons/128x128.png "${PREFIX}/Menu/tolaria.png"
    ;;

  *)
    echo "ERROR: unsupported target_platform: ${target_platform}" >&2
    exit 1
    ;;
esac

# menuinst manifest (cross-platform). The runtime menuinst service registers
# the app in the OS launcher (Apps menu / Applications) from this.
cp "${RECIPE_DIR}/tolaria-menu.json" "${PREFIX}/Menu/tolaria-menu.json"

echo "=== Build complete ==="
