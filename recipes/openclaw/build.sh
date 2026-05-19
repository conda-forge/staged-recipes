#!/usr/bin/env bash
set -exo pipefail

export npm_config_build_from_source=true
export npm_config_node_gyp="${BUILD_PREFIX}/bin/node-gyp"

npm install -g --prefix "${PREFIX}" node-gyp-build

# Create license report for dependencies
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json
pnpm install --prod
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
mv package.json.bak package.json

CI=true pnpm install --no-frozen-lockfile
pnpm build
pnpm ui:build
pnpm pack --config.ignore-scripts=true
npm install -ddd \
    --global \
    --prefix "${PREFIX}" \
    --build-from-source \
    --no-bin-links \
    ${PKG_NAME}-${PKG_VERSION}.tgz

# Create wrapper scripts
tee ${PREFIX}/bin/openclaw << 'EOF'
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/openclaw/openclaw.mjs" "$@"
EOF
chmod +x ${PREFIX}/bin/openclaw

tee ${PREFIX}/bin/openclaw.cmd << 'EOF'
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\openclaw\openclaw.mjs %*
EOF
