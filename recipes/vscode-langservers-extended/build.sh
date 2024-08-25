#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Run pnpm so that pnpm-licenses can create report
pnpm install
pnpm pack

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/vscode-css-language-server.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\vscode-css-language-server %*
EOF

tee ${PREFIX}/bin/vscode-eslint-language-server.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\vscode-eslint-language-server %*
EOF

tee ${PREFIX}/bin/vscode-html-language-server.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\vscode-html-language-server %*
EOF

tee ${PREFIX}/bin/vscode-json-language-server.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\vscode-json-language-server %*
EOF

tee ${PREFIX}/bin/vscode-markdown-language-server.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\vscode-markdown-language-server %*
EOF
