#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
git remote set-url origin https://github.com/coverlet-coverage/coverlet
dotnet publish --no-self-contained src/coverlet.console/coverlet.console.csproj --output ${PREFIX}/libexec/${PKG_NAME} /p:RunAnalyzers=False -c Release
rm ${PREFIX}/libexec/${PKG_NAME}/coverlet.console

# Create bash and batch wrappers
tee ${PREFIX}/bin/coverlet << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/coverlet/coverlet.console.dll "\$@"
EOF

tee ${PREFIX}/bin/coverlet.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\coverlet\coverlet.console.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
dotnet-project-licenses --input src/coverlet.console/coverlet.console.csproj -t -d license-files
