#!/usr/bin/env bash
set -exo pipefail

# Install dependencies exactly from package-lock.json
npm ci --ignore-scripts

# Build lib/ from TypeScript source
npm run build

# Generate production-only license report
cp package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json

rm -rf node_modules
npm install -ddd --omit=dev --ignore-scripts --package-lock=false

pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

mv package.json.bak package.json

# Pack built package. Avoid re-running prepare.
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
