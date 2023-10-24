#!/bin/bash

set -exuo pipefail

# This code includes code from https://github.com/conda-forge/openvscode-server-feedstock
# which is licensed under the BSD-3-Clause License.

rm $PREFIX/bin/node
ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node

export NODE_OPTIONS=--openssl-legacy-provider

pushd sagemaker-code-editor
pushd src

# Install remote extensions for target_platform
pushd remote
  VSCODE_RIPGREP_VERSION=$(jq -r '.dependencies."@vscode/ripgrep"' package.json)
  # Install all dependencies except @vscode/ripgrep
  mv package.json package.json.orig
  jq 'del(.dependencies."@vscode/ripgrep")' package.json.orig > package.json

  yarn install
  # Install @vscode/ripgrep without downloading the pre-built ripgrep.
  # This often runs into Github API ratelimits and we won't use the binary in this package anyways.
  yarn add --ignore-scripts "@vscode/ripgrep@${VSCODE_RIPGREP_VERSION}"
popd

# Install build tools for build_platform
(
  unset CFLAGS
  unset CXXFLAGS
  unset CPPFLAGS
  unset npm_config_arch
  export CC=${CC_FOR_BUILD}
  export CXX=${CXX_FOR_BUILD}
  export AR="$($CC_FOR_BUILD -print-prog-name=ar)"
  export NM="$($CC_FOR_BUILD -print-prog-name=nm)"
  export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
  export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig
  VSCODE_RIPGREP_VERSION=$(jq -r '.dependencies."@vscode/ripgrep"' package.json)
  VSCODE_TELEMETRY_VERSION=$(jq -r '.devDependencies."@vscode/telemetry-extractor"' package.json)
  # Install all dependencies except @vscode/ripgrep
  mv package.json package.json.orig
  jq 'del(.dependencies."@vscode/ripgrep")' package.json.orig | jq 'del(.devDependencies."@vscode/telemetry-extractor")' > package.json
  yarn install
  # Install @vscode/ripgrep without downloading the pre-built ripgrep.
  # This often runs into Github API ratelimits and we won't use the binary in this package anyways.
  yarn add --ignore-scripts "@vscode/ripgrep@${VSCODE_RIPGREP_VERSION}" "@vscode/telemetry-extractor@${VSCODE_TELEMETRY_VERSION}"
)
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

# Replace bundled ripgrep with conda package
mkdir -p ${PREFIX}/share/sagemaker-code-editor/node_modules/@vscode/ripgrep/bin
cat <<EOF >${PREFIX}/share/sagemaker-code-editor/node_modules/@vscode/ripgrep/bin/rg
#!/bin/bash
exec "${PREFIX}/bin/rg" "\$@"
EOF
chmod +x ${PREFIX}/share/sagemaker-code-editor/node_modules/@vscode/ripgrep/bin/rg

# Test sagemaker-code-editor and ripgrep
if [[ "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
  ${PREFIX}/share/sagemaker-code-editor/node_modules/@vscode/ripgrep/bin/rg --help

  # Directly check whether the sagemaker-code-editor call also works inside of conda-build
  sagemaker-code-editor --help
fi