#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Pack the package and install it globally into the conda prefix.
# `npm install --global` creates the bin shims for us.
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    "${SRC_DIR}/yo-${PKG_VERSION}.tgz"

# npm creates symlinks under each transitive dep's node_modules/.bin/
# (ejs, jake, semver, yosay, …). rattler-build's noarch validator
# rejects these as non-portable on Windows. yo never invokes them via
# `npm exec` at runtime — the top-level `yo` shim discovers and
# dispatches to generators directly — so the safe fix is to drop them
# after install. (See SKILL.md G6.)
find "${PREFIX}/lib/node_modules/yo" -type d -name .bin -exec rm -rf {} +

# `npm install --global` also creates `${PREFIX}/bin/yo` as a symlink
# pointing at `../lib/node_modules/yo/lib/cli.js`. rattler-build's
# noarch validator rejects it for the same Windows-portability reason
# (a noarch:generic artifact extracts verbatim on Windows). Replace the
# symlink with a small portable wrapper that resolves the cli.js path
# relative to its own location so it works regardless of activation.
rm -f "${PREFIX}/bin/yo"
cat > "${PREFIX}/bin/yo" << 'EOF'
#!/bin/sh
HERE="$(cd "$(dirname "$0")" && pwd)"
exec node "${HERE}/../lib/node_modules/yo/lib/cli.js" "$@"
EOF
chmod +x "${PREFIX}/bin/yo"

# Generate the third-party license disclaimer (required by conda-forge
# for npm packages with runtime dependencies — declared in
# `about.license_file`).
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Windows .cmd wrapper (the noarch build runs on Linux but the package
# needs to be usable on Windows once installed). Use %~dp0 to resolve
# cli.js relative to the .cmd's own directory.
tee "${PREFIX}/bin/yo.cmd" << 'EOF'
@echo off
node "%~dp0..\lib\node_modules\yo\lib\cli.js" %*
EOF
