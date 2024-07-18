#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"

# Backport version update from upstream
sed -i 's/6.7.0/6.8.1/g' src/Cake.NuGet/Cake.NuGet.csproj

# Build package with dotnet publish
dotnet publish --no-self-contained src/Cake/Cake.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}
rm ${PREFIX}/libexec/${PKG_NAME}/Cake

# Create bash and batch wrappers
tee ${PREFIX}/bin/cake << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/cake/Cake.dll "\$@"
EOF

tee ${PREFIX}/bin/cake.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\cake\Cake.dll %*
EOF

# Download licenses with dotnet-project-licenses
dotnet-project-licenses --input src/Cake/Cake.csproj -t -d license-files
