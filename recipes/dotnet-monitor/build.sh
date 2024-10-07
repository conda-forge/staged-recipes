#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
cp global.json global_old.json
jq 'del(.tools)' global_old.json > global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained src/Tools/dotnet-monitor/dotnet-monitor.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework "net${framework_version}"
rm ${PREFIX}/libexec/${PKG_NAME}/dotnet-monitor
rm -rf ${PREFIX}/libexec/${PKG_NAME}/shims

# Create bash and batch wrappers
tee ${PREFIX}/bin/dotnet-monitor << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/dotnet-monitor/dotnet-monitor.dll "\$@"
EOF

tee ${PREFIX}/bin/dotnet-monitor.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\dotnet-monitor\dotnet-monitor.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
dotnet-project-licenses --input src/Tools/dotnet-monitor/dotnet-monitor.csproj -t -d license-files
