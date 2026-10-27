#!/usr/bin/env bash
set -euo pipefail

# --ignore-scripts skips the package's prepack/prepare hooks
npm pack --ignore-scripts
npm install -g --ignore-scripts --omit=dev --no-audit --no-fund \
  --prefix "$PREFIX" ./rea-agents-*.tgz

# Remove unused test directories
find "$PREFIX/lib/node_modules/rea-agents" -type d \( -name test -o -name tests \) -prune -exec rm -rf {} +