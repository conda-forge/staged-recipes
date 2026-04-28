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
# raw binary directly; updater needs an upstream-managed signing key we don't
# have access to).
TAURI_OVERRIDE='{"bundle":{"createUpdaterArtifacts":false}}'

# Conda-forge's rust compiler activation passes --target=<triple>, so cargo
# outputs to target/<triple>/release/ instead of target/release/. Detect the
# triple from rustc and prefer that path; fall back to the un-triplet path
# for build environments without an explicit --target.
RUST_TARGET="$(rustc -vV | awk '/^host:/ {print $2}')"

case "${target_platform}" in
  osx-arm64)
    echo "=== macOS arm64 build (.app bundle) ==="
    # --bundles app skips .dmg + updater. We need the full .app for Tauri's
    # macOS resource resolution (looks at <exe>/../Resources via Info.plist).
    pnpm tauri build --bundles app --config "${TAURI_OVERRIDE}"

    APP_SRC="src-tauri/target/${RUST_TARGET}/release/bundle/macos/Tolaria.app"
    [[ -d "${APP_SRC}" ]] || APP_SRC="src-tauri/target/release/bundle/macos/Tolaria.app"
    [[ -d "${APP_SRC}" ]]

    mkdir -p "${PREFIX}/lib"
    cp -R "${APP_SRC}" "${PREFIX}/lib/Tolaria.app"

    # Apple Silicon refuses to load unsigned arm64 binaries. Tauri produces
    # an unsigned bundle when no signingIdentity is configured — ad-hoc sign
    # so the conda-installed app actually runs.
    codesign --force --deep --sign - "${PREFIX}/lib/Tolaria.app"
    codesign --verify "${PREFIX}/lib/Tolaria.app"

    # Launcher script. menuinst points at this; the launcher exec's into
    # the bundled binary so Tauri's Info.plist + Resources resolution works.
    mkdir -p "${PREFIX}/bin"
    cat > "${PREFIX}/bin/tolaria" << 'EOF'
#!/bin/bash
exec "$(dirname "$0")/../lib/Tolaria.app/Contents/MacOS/Tolaria" "$@"
EOF
    chmod +x "${PREFIX}/bin/tolaria"

    # menuinst icon
    mkdir -p "${PREFIX}/Menu"
    cp src-tauri/icons/icon.icns "${PREFIX}/Menu/tolaria.icns"
    ;;

  linux-64)
    echo "=== Linux x86_64 build (raw binary) ==="
    # --no-bundle: produce only target/release/tolaria, skip the
    # .deb/.AppImage/.rpm bundlers (which would just be repackaged out
    # of conda's prefix layout anyway). Mirrors conda-forge/nebi-feedstock.
    pnpm tauri build --no-bundle --config "${TAURI_OVERRIDE}"

    BIN_SRC="src-tauri/target/${RUST_TARGET}/release/tolaria"
    [[ -x "${BIN_SRC}" ]] || BIN_SRC="src-tauri/target/release/tolaria"
    [[ -x "${BIN_SRC}" ]]

    mkdir -p "${PREFIX}/bin"
    cp "${BIN_SRC}" "${PREFIX}/bin/tolaria"

    # Stage MCP server resources at Tauri's expected runtime location.
    # tauri::path::resource_dir() on Linux falls back to <exe>/../lib/<bundle_id>/.
    # The mcp-server tree is populated under src-tauri/resources/ by Tauri's
    # beforeBuildCommand (`pnpm bundle-mcp`) before the cargo build runs.
    BUNDLE_ID="club.refactoring.tolaria"
    mkdir -p "${PREFIX}/lib/${BUNDLE_ID}"
    cp -R src-tauri/resources/mcp-server "${PREFIX}/lib/${BUNDLE_ID}/"

    # menuinst icon
    mkdir -p "${PREFIX}/Menu"
    cp src-tauri/icons/128x128.png "${PREFIX}/Menu/tolaria.png"
    ;;

  *)
    echo "ERROR: unsupported target_platform: ${target_platform}" >&2
    exit 1
    ;;
esac

# menuinst manifest (cross-platform). The runtime menuinst service uses this
# to register the app in the OS launcher (Apps menu / Start menu / Applications).
cp "${RECIPE_DIR}/tolaria-menu.json" "${PREFIX}/Menu/tolaria-menu.json"

echo "=== Build complete ==="
