#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Repack the extracted npm tarball so npm installs exactly the published files
npm pack --ignore-scripts
npm install -ddd --global --no-bin-links "${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz"

# License report for the bundled runtime dependency tree
pnpm install --prod --ignore-scripts
pnpm licenses list --json --prod | pnpm-licenses generate-disclaimer --prod --json-input --output-file=third-party-licenses.txt

mkdir -p "${PREFIX}/bin"
tee "${PREFIX}/bin/codeburn" <<SHIM
#!/bin/sh
exec "\${CONDA_PREFIX}/bin/node" "\${CONDA_PREFIX}/lib/node_modules/codeburn/dist/cli.js" "\$@"
SHIM
chmod +x "${PREFIX}/bin/codeburn"

tee "${PREFIX}/bin/codeburn.cmd" <<SHIM
call %CONDA_PREFIX%\node.exe %CONDA_PREFIX%\lib\node_modules\codeburn\dist\cli.js %*
SHIM
