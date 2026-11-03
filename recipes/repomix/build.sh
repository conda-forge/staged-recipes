#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Pack the already-compiled source and install globally without creating bin symlinks
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --no-bin-links \
    --build-from-source \
    ${SRC_DIR}/repomix-${PKG_VERSION}.tgz

# Generate third-party license disclaimer for all production dependencies
pnpm install --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Create explicit wrapper scripts (needed because --no-bin-links skips npm's own wrappers)
mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/repomix <<EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/repomix/bin/repomix.cjs "\$@"
EOF
chmod +x ${PREFIX}/bin/repomix

tee ${PREFIX}/bin/repomix.cmd <<EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\repomix\bin\repomix.cjs %*
EOF
