#!/bin/bash

set -exuo pipefail

mkdir -p $PREFIX/share
cp -r openvscode-server ${PREFIX}/share/
rm -rf $PREFIX/share/openvscode-server/bin

mkdir -p ${PREFIX}/bin

cat <<'EOF' >${PREFIX}/bin/openvscode-server
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
node "${PREFIX_DIR}/share/openvscode-server/out/vs/server/main.js" "$@"
EOF
chmod +x ${PREFIX}/bin/openvscode-server

# Remove unnecessary resources
find ${PREFIX}/share/openvscode-server -name '*.map' -delete
rm -rf ${PREFIX}/share/openvscode-server/node

# Directly check whether the openvscode-server call also works inside of conda-build
openvscode-server --help
