#!/usr/bin/env bash
set -euo pipefail

# --ignore-scripts skips the package's prepack/prepare hooks
npm pack --ignore-scripts
npm install -g --ignore-scripts --omit=dev --no-audit --no-fund \
  --prefix "$PREFIX" ./rea-agents-*.tgz

# Remove test fixtures with spaces in their paths (thread-stream),
# which trigger rattler-build's "Path contains spaces" warning
find "$PREFIX/lib/node_modules/rea-agents" -name "* *" -prune -exec rm -rf {} +