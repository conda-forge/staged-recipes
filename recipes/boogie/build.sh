#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" Source/Directory.Build.props
dotnet publish --no-self-contained Source/BoogieDriver/BoogieDriver.csproj --output ${PREFIX}/libexec/${PKG_NAME}
rm ${PREFIX}/libexec/${PKG_NAME}/BoogieDriver

# Create bash and batch wrappers
tee ${PREFIX}/bin/boogie << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/boogie/BoogieDriver.dll "\$@"
EOF

tee ${PREFIX}/bin/boogie.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\boogie\BoogieDriver.dll %*
EOF

dotnet-project-licenses --input Source/BoogieDriver/BoogieDriver.csproj -t -d license-files
