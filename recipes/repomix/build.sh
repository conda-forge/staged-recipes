#!/usr/bin/env bash
set -exo pipefail

# Build from GitHub/source tree
pnpm install --frozen-lockfile
pnpm run build

# Generate license report before package.json is modified
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Pack built package. --ignore-scripts avoids re-running prepare.
TARBALL="$(npm pack --ignore-scripts | tail -n 1)"

# Install from tarball, not from local directory.
npm install -ddd \
  --global \
  --prefix "${PREFIX}" \
  --ignore-scripts \
  --no-bin-links \
  "./${TARBALL}"

# Create wrappers manually
mkdir -p "${PREFIX}/bin"

cat > "${PREFIX}/bin/repomix" <<'EOF'
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/repomix/bin/repomix.cjs" "$@"
EOF
chmod +x "${PREFIX}/bin/repomix"

cat > "${PREFIX}/bin/repomix.cmd" <<'EOF'
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\repomix\bin\repomix.cjs %*
EOF
