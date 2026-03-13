#!/usr/bin/env bash
set -o xtrace -o nounset -o pipefail -o errexit

# ============================================================
# Phase 1: Create .env for dotenv-webpack build-time injection
# ============================================================
cat > .env << 'EOF'
NODE_ENV=production
BRIDGE_URL=https://api.internxt.com
DRIVE_URL=https://drive.internxt.com
PAYMENTS_URL=https://payments.internxt.com
NOTIFICATIONS_URL=https://notifications.internxt.com
DESKTOP_HEADER=internxt-drive-desktop
NEW_CRYPTO_KEY=PLACEHOLDER_USER_MUST_CONFIGURE
ANALYZE=false
PORT=3000
EOF

# ============================================================
# Phase 2: Install JavaScript dependencies
# ============================================================
# This project uses the Electron React Boilerplate layout:
#   root package.json       -> dev dependencies (webpack, typescript, etc.)
#   release/app/package.json -> runtime dependencies (typeorm, better-sqlite3, fuse)
# Source code imports runtime deps via relative paths into release/app/node_modules/.
# Both directories need npm install.

# Root dev dependencies (--ignore-scripts to skip premature electron-rebuild)
npm ci --ignore-scripts

# Runtime dependencies in release/app/
pushd release/app
npm ci --ignore-scripts
popd

# Download the Electron binary (skipped by --ignore-scripts)
node node_modules/electron/install.js

# ============================================================
# Phase 3: Rebuild native modules for Electron's Node ABI
# ============================================================
export npm_config_build_from_source=true

# Rebuild native modules in release/app/node_modules (typeorm, better-sqlite3, fuse)
npx electron-rebuild --force --types prod,dev,optional

# ============================================================
# Phase 4: Webpack production build (main + renderer + preload)
# ============================================================
npm run build

# ============================================================
# Phase 5: Prune devDependencies to reduce package size
# ============================================================
npm prune --production

pushd release/app
npm prune --production
popd

# ============================================================
# Phase 6: Install into conda prefix
# ============================================================
INSTALL_DIR="${PREFIX}/lib/internxt-drive"

mkdir -p "${INSTALL_DIR}"

# Copy webpack build output (lives under release/app/dist/ after build)
if [ -d release/app/dist ]; then
    cp -r release/app/dist "${INSTALL_DIR}/dist"
else
    # Fallback: some versions output to root dist/
    cp -r dist "${INSTALL_DIR}/dist"
fi

# Copy release/app runtime node_modules (native modules + runtime deps)
cp -r release/app/node_modules "${INSTALL_DIR}/node_modules"

# Copy release/app/package.json (electron needs it to resolve the main entry)
cp release/app/package.json "${INSTALL_DIR}/package.json"

# Also copy root node_modules/.bin/electron for the launcher
mkdir -p "${INSTALL_DIR}/node_modules/.bin"
if [ -f node_modules/.bin/electron ]; then
    cp -r node_modules/electron "${INSTALL_DIR}/node_modules/"
    ln -sf ../electron/cli.js "${INSTALL_DIR}/node_modules/.bin/electron"
fi

# Copy assets if present
if [ -d assets ]; then
    cp -r assets "${INSTALL_DIR}/assets"
fi

# ============================================================
# Phase 7: Create launcher script
# ============================================================
mkdir -p "${PREFIX}/bin"

cat > "${PREFIX}/bin/internxt-drive" << 'LAUNCHER'
#!/usr/bin/env bash
APP_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")/lib/internxt-drive"
exec "${APP_DIR}/node_modules/.bin/electron" "${APP_DIR}" "$@"
LAUNCHER

chmod +x "${PREFIX}/bin/internxt-drive"

# ============================================================
# Phase 8: Generate third-party license report
# ============================================================
pnpm install --no-frozen-lockfile 2>/dev/null || true
pnpm-licenses generate-disclaimer --prod --output-file="${SRC_DIR}/third-party-licenses.txt" || {
    echo "WARNING: pnpm-licenses failed, creating placeholder"
    echo "Third-party licenses could not be generated automatically." > "${SRC_DIR}/third-party-licenses.txt"
}

echo "Build completed successfully."
