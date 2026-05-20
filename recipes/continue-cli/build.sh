#!/usr/bin/env bash
set -exo pipefail

# Install globally
pnpm pack --config.ignore-scripts=true
npm install -ddd \
    --global \
    --prefix "${PREFIX}" \
    --build-from-source \
    --no-bin-links \
    continuedev-cli-${PKG_VERSION}.tgz

# Create license report for dependencies
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json

# Create license report for dependencies
pnpm install --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Create wrapper scripts
tee ${PREFIX}/bin/cn << 'EOF'
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/@continuedev/cli/dist/cn.js" "$@"
EOF
chmod +x ${PREFIX}/bin/cn

tee ${PREFIX}/bin/cn.cmd << 'EOF'
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\@continuedev\cli\dist\cn.js %*
EOF
