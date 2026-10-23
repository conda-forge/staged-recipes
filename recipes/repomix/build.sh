#!/usr/bin/env bash

set -euxo pipefail

export PATH="${BUILD_PREFIX}/bin:${PATH}"
export NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

# Pack the published files and install them into the target prefix.
pnpm pack --config.ignore-scripts=true
npm install -ddd \
    --global \
    --prefix "${PREFIX}" \
    --ignore-scripts \
    --no-bin-links \
    "${PKG_NAME}-${PKG_VERSION}.tgz"

# Upstream does not publish a lockfile. Generate an npm lockfile first so that
# pnpm can import the resolved production dependency graph for license reporting.
npm pkg delete devDependencies
npm install --package-lock-only --omit=dev --ignore-scripts
pnpm import
pnpm install --prod --frozen-lockfile --ignore-scripts
pnpm licenses list --prod --json \
    | pnpm-licenses generate-disclaimer \
        --json-input \
        --output-file=third-party-licenses.txt

# Create the POSIX wrapper.
mkdir -p "${PREFIX}/bin"
tee "${PREFIX}/bin/repomix" << 'EOF'
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/repomix/bin/repomix.cjs" "$@"
EOF
chmod +x "${PREFIX}/bin/repomix"
