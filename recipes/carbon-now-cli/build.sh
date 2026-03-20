#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# Strip lifecycle scripts that interfere with packaging (husky, playwright)
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
delete pkg.scripts.prepare;
delete pkg.scripts.postinstall;
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
"

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    --ignore-scripts \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
delete pkg.devDependencies;
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
"

pnpm install --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/carbon-now << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/carbon-now-cli/bundle/cli.js "\$@"
EOF
chmod +x ${PREFIX}/bin/carbon-now

tee ${PREFIX}/bin/carbon-now.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\carbon-now-cli\bundle\cli.js %*
EOF
