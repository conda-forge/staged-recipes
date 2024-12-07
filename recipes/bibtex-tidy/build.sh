#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create batch wrapper
tee ${PREFIX}/bin/bibtex-tidy.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\bibtex-tidy %*
EOF
