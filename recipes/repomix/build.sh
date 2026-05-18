#!/usr/bin/env bash
set -exo pipefail

PKG_DIR="${PREFIX}/lib/node_modules/repomix"
mkdir -p "${PKG_DIR}"

# Copy the already-built npm package contents
cp -R package.json lib bin README.md LICENSE "${PKG_DIR}/"

# Install production dependencies into the package directory
pushd "${PKG_DIR}"
npm install -ddd --omit=dev --ignore-scripts
popd

# License report
cp package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json
pnpm install --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Wrappers
mkdir -p "${PREFIX}/bin"

cat > "${PREFIX}/bin/repomix" <<'EOF'
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/repomix/bin/repomix.cjs" "$@"
EOF
chmod +x "${PREFIX}/bin/repomix"

cat > "${PREFIX}/bin/repomix.cmd" <<'EOF'
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\repomix\bin\repomix.cjs %*
EOF
