#!/bin/bash
set -euxo pipefail

# conda-build sets SRC_DIR to the single top-level directory in the archive.
# npm tarballs extract into package/, so SRC_DIR should already be package/.
if [ ! -f "package.json" ]; then
    echo "ERROR: package.json not found in SRC_DIR: $(pwd)" >&2
    ls -la
    exit 1
fi

# Install production npm dependencies (no devDependencies, no scripts)
npm install --omit=dev --no-fund --no-audit --ignore-scripts

# Create the installation directory
INSTALL_DIR="${PREFIX}/lib/node_modules/${PKG_NAME}"
mkdir -p "${INSTALL_DIR}"

# Copy all package files (source + node_modules)
cp -r . "${INSTALL_DIR}/"

# Create bin directory
mkdir -p "${PREFIX}/bin"

# Create wrapper for the bmad command
cat > "${PREFIX}/bin/bmad" << 'WRAPPER'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec node "${SCRIPT_DIR}/../lib/node_modules/bmad-method/tools/bmad-npx-wrapper.js" "$@"
WRAPPER
chmod +x "${PREFIX}/bin/bmad"

# Create wrapper for the bmad-method command (same entry point)
cat > "${PREFIX}/bin/bmad-method" << 'WRAPPER'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec node "${SCRIPT_DIR}/../lib/node_modules/bmad-method/tools/bmad-npx-wrapper.js" "$@"
WRAPPER
chmod +x "${PREFIX}/bin/bmad-method"
