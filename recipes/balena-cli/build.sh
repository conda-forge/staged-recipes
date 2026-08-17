#!/bin/bash
set -euo pipefail

# Install production dependencies and build TypeScript sources
npm install --production=false --ignore-scripts 2>&1
# Run postinstall (applies patches)
node patches/apply-patches.js

# Build: compile TypeScript and generate oclif manifest
npx tsc
npx oclif manifest

# Remove dev dependencies after build
npm prune --production

# Remove prebuilt native binaries for non-target platforms.
# npm packages ship prebuilds for android, ios, arm, musl, ia32, etc.
# We only need linux-x64 glibc binaries.
find node_modules -type d -path '*/prebuilds/android-*' -exec rm -rf {} + 2>/dev/null || true
find node_modules -type d -path '*/prebuilds/ios-*' -exec rm -rf {} + 2>/dev/null || true
find node_modules -type d -path '*/prebuilds/darwin-*' -exec rm -rf {} + 2>/dev/null || true
find node_modules -type d -path '*/prebuilds/win32-*' -exec rm -rf {} + 2>/dev/null || true
find node_modules -type d -path '*/prebuilds/linux-arm*' -exec rm -rf {} + 2>/dev/null || true
find node_modules -type d -path '*/prebuilds/linux-ia32' -exec rm -rf {} + 2>/dev/null || true
find node_modules -type d -path '*/prebuilds/linux-arm64' -exec rm -rf {} + 2>/dev/null || true
# Remove musl-linked and electron-specific binaries from linux-x64
find node_modules -path '*/prebuilds/linux-x64/*musl*' -delete 2>/dev/null || true
find node_modules -path '*/prebuilds/linux-x64/*electron*' -delete 2>/dev/null || true
# Remove bare-* prebuilds (unused on Node.js)
find node_modules -path '*/bare-*/prebuilds' -type d -exec rm -rf {} + 2>/dev/null || true
# Remove raspberry pi blobs
find node_modules -path '*/node-raspberrypi-usbboot/blobs' -type d -exec rm -rf {} + 2>/dev/null || true

# Install the package into PREFIX
DEST="${PREFIX}/lib/balena-cli"
mkdir -p "${DEST}"
cp -r bin build node_modules package.json npm-shrinkwrap.json oclif.manifest.json "${DEST}/"
# Copy patches dir (needed for postinstall on future npm rebuild)
cp -r patches "${DEST}/"

# Create wrapper script
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/balena" << 'EOF'
#!/bin/bash
exec node "${CONDA_PREFIX}/lib/balena-cli/bin/run.js" "$@"
EOF
chmod +x "${PREFIX}/bin/balena"
