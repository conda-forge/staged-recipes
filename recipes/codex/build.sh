# set -euxo pipefail

# pnpm install #@openai/codex@$PKG_VERSION --prefix=$PREFIX
# pnpm list

# pushd $PREFIX/
# pnpm-licenses generate-disclaimer --prod --output-file=$SRC_DIR/third-party-licenses.txt
# popd

#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Patch package.json to skip unnecessary prepare step
mv package.json package.json.bak
jq "del(.scripts.prepare)" < package.json.bak > package.json

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ./openai-codex-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Create batch wrapper
tee ${PREFIX}/bin/codex.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\codex %*
EOF