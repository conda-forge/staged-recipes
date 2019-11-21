#!/bin/bash

set -euo pipefail
set -x

VERSION=${PKG_VERSION//_/-}

vscodeVersion=$(python -c "print('${VERSION}'.split('-vsc')[1])")
codeServerVersion=$(python -c "print('${VERSION}'.split('-vsc')[0])")

yarn
MINIFY=true yarn build "${vscodeVersion}" "${codeServerVersion}"
yarn binary "${vscodeVersion}" "${codeServerVersion}"
mkdir -p ${PREFIX}/bin/
mv binaries/code-server${VERSION}-*-x86_64 ${PREFIX}/bin/code-server
