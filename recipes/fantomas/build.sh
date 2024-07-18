#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
dotnet publish --no-self-contained src/Fantomas/Fantomas.fsproj --output ${PREFIX}/libexec/${PKG_NAME}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/fantomas

# Create bash and batch wrappers
tee ${PREFIX}/bin/fantomas << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/fantomas/fantomas.dll "\$@"
EOF

tee ${PREFIX}/bin/fantomas.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\fantomas\fantomas.dll %*
EOF

# Download dependency licenses with dotnet-project-licenses
dotnet-project-licenses --input src/Fantomas/Fantomas.fsproj -t -d license-files
