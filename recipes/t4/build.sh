#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFrameworks>net${framework_version}</TargetFrameworks>?" \
    dotnet-t4/dotnet-t4.csproj
dotnet publish --no-self-contained dotnet-t4/dotnet-t4.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}
rm ${PREFIX}/libexec/${PKG_NAME}/t4

# Create bash and batch wrappers
tee ${PREFIX}/bin/t4 << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/t4/t4.dll "\$@"
EOF

tee ${PREFIX}/bin/t4.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\t4\t4.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
dotnet-project-licenses --input dotnet-t4/dotnet-t4.csproj -t -d license-files
