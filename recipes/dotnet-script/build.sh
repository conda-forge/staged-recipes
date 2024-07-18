#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained src/Dotnet.Script/Dotnet.Script.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework "net${framework_version}"

# Create bash and batch wrappers
tee ${PREFIX}/bin/dotnet-script << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/dotnet-script/dotnet-script.dll "\$@"
EOF

tee ${PREFIX}/bin/dotnet-script.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\dotnet-script\dotnet-script.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
dotnet-project-licenses -e --input . -f license-files
