#!/bin/bash
set -euxo pipefail

# rattler-build / conda-build set SRC_DIR; fall back to pwd for local debug.
SRC_ROOT="${SRC_DIR:-$(pwd)}"
cd "${SRC_ROOT}"

echo "=== Build environment ==="
echo "SRC_ROOT: ${SRC_ROOT}"
echo "PREFIX:   ${PREFIX}"
echo "Node:     $(node --version)"
echo "Python:   $(python --version)"

# --- pnpm via corepack ------------------------------------------------------
# corepack ships with the conda-forge nodejs build (Node >= 16.13).
export COREPACK_HOME="${SRC_ROOT}/.corepack"
corepack enable --install-directory "${BUILD_PREFIX}/bin"
corepack prepare "pnpm@${PKG_VERSION_PNPM:-10.33.2}" --activate
pnpm --version

# --- memory tuning ----------------------------------------------------------
# `tsc -b` for the workspace and the better-sqlite3 native build can spike RAM.
export NODE_OPTIONS="--max-old-space-size=4096"

# --- strip heavyweight root postinstall -------------------------------------
# Upstream's `postinstall: node ./scripts/postinstall.mjs` builds every
# workspace under packages/* and tools/* — pulling in electron-builder,
# 7zip-bin arm64 binaries, and esbuild deps that the daemon doesn't need.
# pnpm's `--ignore-scripts` only suppresses *dependency* install scripts;
# the root project's own lifecycle scripts run regardless. Strip the script
# from package.json before install so the workspace's daemon build chain
# (which runs explicitly via `pnpm --filter ... run build` below) is the
# only thing that runs.
python -c "
import json, pathlib
p = pathlib.Path('package.json')
d = json.loads(p.read_text())
d.get('scripts', {}).pop('postinstall', None)
p.write_text(json.dumps(d, indent=2))
"

# --- filtered install -------------------------------------------------------
# `--filter '@open-design/daemon...'` resolves only the daemon's transitive
# workspace + npm dep tree. pnpm still populates .pnpm/ for everything in
# the lockfile, which is fine because we ship via `pnpm deploy` (below), not
# via copying the workspace node_modules.
pnpm install \
  --frozen-lockfile \
  --strict-peer-dependencies=false \
  --ignore-scripts \
  --filter '@open-design/daemon...'

# Compile better-sqlite3 explicitly (we skipped install scripts above)
pnpm --filter '@open-design/daemon' rebuild better-sqlite3

# --- build the workspace dep chain ------------------------------------------
# sidecar-proto → sidecar → platform → daemon (`@open-design/contracts` is
# TS-source-only and has no build step).
pnpm --filter '@open-design/daemon...' run build

# --- third-party license aggregation ----------------------------------------
pnpm --filter '@open-design/daemon' licenses list --prod --long \
  > "${SRC_ROOT}/ThirdPartyNotices.txt" || {
    echo "WARNING: pnpm licenses list failed; emitting placeholder"
    echo "Third-party license texts could not be enumerated automatically." \
      > "${SRC_ROOT}/ThirdPartyNotices.txt"
  }
ls -la "${SRC_ROOT}/LICENSE" "${SRC_ROOT}/ThirdPartyNotices.txt"

# --- standalone deployment via `pnpm deploy` --------------------------------
# `pnpm deploy` produces a *flat* node_modules with only the daemon's actual
# prod deps — no .pnpm store, no path-length issues, no cross-package leakage,
# no electron-builder / 7zip-bin arm64 binaries from sibling workspaces.
DEPLOY_DIR="${SRC_ROOT}/.deploy/open-design"
rm -rf "${DEPLOY_DIR}"
pnpm deploy --filter '@open-design/daemon' --prod --legacy "${DEPLOY_DIR}"

# --- stage to PREFIX --------------------------------------------------------
INSTALL_DIR="${PREFIX}/lib/${PKG_NAME}"
mkdir -p "${INSTALL_DIR}"
cp -r "${DEPLOY_DIR}/." "${INSTALL_DIR}/"

# --- launcher ---------------------------------------------------------------
# `pnpm deploy --legacy` lays the daemon out at the deploy-dir root: dist/,
# package.json, node_modules/. The launcher invokes node on dist/cli.js.
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/od" << 'WRAPPER'
#!/usr/bin/env bash
# Open Design daemon launcher (conda)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec node "${SCRIPT_DIR}/../lib/open-design/dist/cli.js" "$@"
WRAPPER
chmod +x "${PREFIX}/bin/od"

echo "=== Install complete ==="
ls -la "${PREFIX}/bin/od"
du -sh "${INSTALL_DIR}" || true
