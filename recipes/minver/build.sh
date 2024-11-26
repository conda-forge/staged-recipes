#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained minver-cli/minver-cli.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework "net${framework_version}"
rm ${PREFIX}/libexec/${PKG_NAME}/minver-cli

# Create bash and batch wrappers
tee ${PREFIX}/bin/minver << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/minver/minver-cli.dll "\$@"
EOF

tee ${PREFIX}/bin/minver.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\minver\minver-cli.dll %*
EOF

dotnet-project-licenses --input minver-cli/minver-cli.csproj -t -d license-files
