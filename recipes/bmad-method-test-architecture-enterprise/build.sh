#!/bin/bash
set -euxo pipefail

# The GitHub archive extracts into <name>-<version>/; rattler-build sets
# SRC_DIR to that top-level directory, so package.json is directly in SRC_DIR.
if [ ! -f "package.json" ]; then
    echo "ERROR: package.json not found in SRC_DIR: $(pwd)" >&2
    ls -la
    exit 1
fi

# Install production npm dependencies (no devDependencies, no scripts).
# --no-bin-links prevents npm from creating node_modules/.bin/ symlinks; those
# symlinks are not portable across platforms and would break the noarch package
# on Windows. This sub-module is consumed as a library, not as a CLI, so the
# bin links serve no purpose here.
npm install --omit=dev --no-fund --no-audit --ignore-scripts --no-bin-links

# Create the installation directory
INSTALL_DIR="${PREFIX}/lib/node_modules/${PKG_NAME}"
mkdir -p "${INSTALL_DIR}"

# Copy all package files (source + node_modules), then remove dev-only directories
# that are present in the GitHub archive but excluded in .npmignore.
cp -r . "${INSTALL_DIR}/"
rm -rf "${INSTALL_DIR}/website" \
       "${INSTALL_DIR}/docs" \
       "${INSTALL_DIR}/test" \
       "${INSTALL_DIR}/.husky" \
       "${INSTALL_DIR}/.github" \
       "${INSTALL_DIR}/.vscode" \
       "${INSTALL_DIR}/.augment" \
       "${INSTALL_DIR}/.claude-plugin"
