#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mv package.json package.json.bak
jq 'del(.scripts.prepare)' package.json.bak > package.json

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

rm ${PREFIX}/bin/add-skill
rm ${PREFIX}/bin/skills

tee ${PREFIX}/bin/skills << EOF
#!/usr/bin/env bash
\${CONDA_PREFIX}/bin/node \${PREFIX}/lib/node_modules/skills/bin/cli.mjs
EOF
chmod +x ${PREFIX}/bin/skills

tee ${PREFIX}/bin/skills.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%/lib/node_modules/skills/bin/cli.mjs %*
EOF
