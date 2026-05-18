#!/usr/bin/env bash
set -exo pipefail

# Install globally
npm install -ddd \
    --global \
    --prefix "${PREFIX}" \
    --ignore-scripts \
    --no-bin-links \
    .

# Create license report for dependencies
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json
pnpm install --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Create wrapper scripts
tee ${PREFIX}/bin/repomix << 'EOF'
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/repomix/dist/index.js" "$@"
EOF
chmod +x ${PREFIX}/bin/repomix

tee ${PREFIX}/bin/repomix.cmd << 'EOF'
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\repomix\dist\index.js %*
EOF
