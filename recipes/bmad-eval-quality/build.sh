#!/bin/bash
set -euxo pipefail

# The GitHub tag archive extracts into bmad-eval-quality-<version>/;
# rattler-build sets SRC_DIR to that directory, so package.json is in SRC_DIR.
if [[ ! -f "package.json" ]]; then
    echo "ERROR: package.json not found in SRC_DIR: ${PWD}" >&2
    ls -la
    exit 1
fi

# dist/ is not committed upstream: compile TypeScript (needs devDependencies).
npm ci --no-fund --no-audit --ignore-scripts
npm run build

# Ship production dependencies only (one prod dep: zod).
rm -rf node_modules
npm ci --omit=dev --no-fund --no-audit --ignore-scripts

INSTALL_DIR="${PREFIX}/lib/node_modules/eval-quality"
mkdir -p "${INSTALL_DIR}"

# Mirror package.json "files" (dist, schemas, corpus, README.md, LICENSE)
# plus package.json and the production node_modules.
cp -r dist schemas corpus README.md LICENSE package.json node_modules "${INSTALL_DIR}/"
# No symlinks in a noarch artifact (rattler-build rejects them for Windows).
find "${INSTALL_DIR}" -type d -name .bin -exec rm -rf {} +

mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/eval-quality" << 'WRAPPER'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec node "${SCRIPT_DIR}/../lib/node_modules/eval-quality/dist/cli/main.js" "$@"
WRAPPER
chmod +x "${PREFIX}/bin/eval-quality"
