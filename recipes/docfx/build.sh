#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained src/docfx/docfx.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework "net${framework_version}"
rm ${PREFIX}/libexec/${PKG_NAME}/docfx
rm -rf ${PREFIX}/libexec/${PKG_NAME}/.playwright

# Create bash and batch wrappers
tee ${PREFIX}/bin/docfx << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/docfx/docfx.dll "\$@"
EOF

tee ${PREFIX}/bin/docfx.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\docfx\docfx.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
tee ignored_packages.json << EOF
["Stubble.Core"]
EOF
dotnet-project-licenses --input src/docfx/docfx.csproj -t -d license-files -ignore ignored_packages.json
