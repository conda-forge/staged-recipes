#!/bin/bash

set -exuo pipefail

# This code includes code from https://github.com/conda-forge/openvscode-server-feedstock
# which is licensed under the BSD-3-Clause License.

export NODE_OPTIONS=--openssl-legacy-provider

# ripgrep tries to download binary from github, copying the ripgrep executable to the cache location so that it doesn't do that 
mkdir /tmp/vscode-ripgrep-cache-1.15.5
mkdir /tmp/vscode-ripgrep-cache-1.15.6
cp "${PREFIX}/bin/rg" /tmp/vscode-ripgrep-cache-1.15.5/
cp "${PREFIX}/bin/rg" /tmp/vscode-ripgrep-cache-1.15.6/

pushd sagemaker-code-editor
pushd src

# Install node-gyp globally as a fix for NodeJS 18.18.2 https://github.com/microsoft/vscode/issues/194665
npm i -g node-gyp
yarn install

ARCH_ALIAS=linux-x64
yarn gulp vscode-reh-web-${ARCH_ALIAS}-min
popd

mkdir -p $PREFIX/share
cp -r vscode-reh-web-${ARCH_ALIAS} ${PREFIX}/share/sagemaker-code-editor
rm -rf $PREFIX/share/sagemaker-code-editor/bin

mkdir -p ${PREFIX}/bin
cat <<'EOF' >${PREFIX}/bin/sagemaker-code-editor
#!/bin/bash
PREFIX_DIR=$(dirname ${BASH_SOURCE})
# Make PREDIX_DIR absolute
if [[ $(uname) == 'Linux' ]]; then
  PREFIX_DIR=$(readlink -f ${PREFIX_DIR})
else
  pushd ${PREFIX_DIR}
  PREFIX_DIR=$(pwd -P)
  popd
fi
# Go one level up
PREFIX_DIR=$(dirname ${PREFIX_DIR})
node "${PREFIX_DIR}/share/sagemaker-code-editor/out/server-main.js" "$@"
EOF
chmod +x ${PREFIX}/bin/sagemaker-code-editor
