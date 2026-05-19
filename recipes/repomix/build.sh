#!/usr/bin/env bash
set -exo pipefail

pnpm import
pnpm install --ignore-scripts
pnpm run build

# Generate production-only license report
cp package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
mv package.json.bak package.json

# Pack built package
TARBALL="$(npm pack --ignore-scripts | tail -n 1)"

# Install from tarball, not local directory, to avoid symlink package body.
npm install -ddd \
  --global \
  --prefix "${PREFIX}" \
  --ignore-scripts \
  --no-bin-links \
  "./${TARBALL}"

mkdir -p "${PREFIX}/bin"

cat > "${PREFIX}/bin/repomix" <<'EOF'
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/repomix/bin/repomix.cjs" "$@"
EOF
chmod +x "${PREFIX}/bin/repomix"

cat > "${PREFIX}/bin/repomix.cmd" <<'EOF'
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\repomix\bin\repomix.cjs %*
EOF
