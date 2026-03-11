#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Run pnpm so that pnpm-licenses can create report
pnpm install

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --no-bin-links \
    --build-from-source \
    ${SRC_DIR}/zed-industries-claude-agent-acp-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Create Unix bin wrapper
mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/claude-agent-acp << 'EOF'
#!/bin/sh
exec node "$CONDA_PREFIX/lib/node_modules/@zed-industries/claude-agent-acp/dist/index.js" "$@"
EOF
chmod +x ${PREFIX}/bin/claude-agent-acp

# Create Windows cmd wrapper (noarch: generic builds on Linux only)
tee ${PREFIX}/bin/claude-agent-acp.cmd << 'EOF'
@call "%CONDA_PREFIX%\bin\node" "%PREFIX%\lib\node_modules\@zed-industries\claude-agent-acp\dist\index.js" %*
EOF
