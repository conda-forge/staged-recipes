#!/bin/bash
set -euxo pipefail

echo "=== Build environment ==="
node --version
pnpm --version

# Vite + React 19 frontend build needs more heap than the Node default.
export NODE_OPTIONS="--max-old-space-size=4096"

# Confirm the vendored pnpm store from source[1] is present.
[[ -d pnpm-store ]]

echo "=== Installing JS workspace dependencies (offline) ==="
# --store-dir + --offline forces pnpm to resolve every package from the
# pre-fetched store unpacked from source[1]; any missing tarball errors out
# instead of silently hitting the npm registry.
pnpm install \
  --offline \
  --frozen-lockfile \
  --strict-peer-dependencies=false \
  --store-dir "$(pwd)/pnpm-store"

echo "=== Building extension + webview ==="
pnpm build

echo "=== Packaging .vsix ==="
mkdir -p out
pnpm vscode:package

VSIX_FILE="out/bmad-dashboard-${PKG_VERSION}.vsix"
[[ -f "${VSIX_FILE}" ]] || {
  echo "ERROR: expected ${VSIX_FILE} not produced by pnpm vscode:package" >&2
  ls -la out/
  exit 1
}

echo "=== Installing .vsix + LICENSE into PREFIX ==="
SHARE="${PREFIX}/share/bmad-dashboard"
mkdir -p "${SHARE}"
cp "${VSIX_FILE}" "${SHARE}/"
cp LICENSE.md README.md CHANGELOG.md "${SHARE}/"

# Cross-platform Python entry point that wraps `code --install-extension`.
mkdir -p "${PREFIX}/bin"
cp "${RECIPE_DIR}/bmad_dashboard_install.py" "${PREFIX}/bin/bmad-dashboard-install"
chmod +x "${PREFIX}/bin/bmad-dashboard-install"

echo "=== Build complete ==="
ls -la "${SHARE}"
