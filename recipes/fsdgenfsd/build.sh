#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${DOTNET_ROOT}/dotnet ${PREFIX}/bin

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained src/fsdgenfsd/fsdgenfsd.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework "net${framework_version}"
rm ${PREFIX}/libexec/${PKG_NAME}/fsdgenfsd

# Create bash and batch wrappers
tee ${PREFIX}/bin/fsdgenfsd << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/fsdgenfsd/fsdgenfsd.dll "\$@"
EOF
chmod +x ${PREFIX}/bin/fsdgenfsd

tee ${PREFIX}/bin/fsdgenfsd.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\fsdgenfsd\fsdgenfsd.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
dotnet-project-licenses --input src/fsdgenfsd/fsdgenfsd.csproj -t -d license-files
rm ${PREFIX}/bin/dotnet
