#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm global.json
dotnet tool restore

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
dotnet publish --no-self-contained Marksman/Marksman.fsproj --output ${PREFIX}/libexec/${PKG_NAME}

mkdir -p ${PREFIX}/bin
rm -rf ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}
tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet exec ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}.dll "\$@"
EOF

dotnet-project-licenses -e --input . -f license-files
