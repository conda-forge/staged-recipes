#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" \
    src/Pickles.CommandLine/Pickles.CommandLine.csproj
sed -i "s/pickles.basedhtmlfiles/Pickles.BaseDhtmlFiles/g" src/Pickles.DocumentationBuilders.Dhtml/Pickles.DocumentationBuilders.Dhtml.csproj
dotnet publish --no-self-contained src/Pickles.CommandLine/Pickles.CommandLine.csproj --output ${PREFIX}/libexec/${PKG_NAME}
rm ${PREFIX}/libexec/${PKG_NAME}/Pickles

# Create bash and batch wrappers
tee ${PREFIX}/bin/pickles << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/pickles/Pickles.dll "\$@"
EOF

tee ${PREFIX}/bin/pickles.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\pickles\Pickles.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
dotnet-project-licenses --input src/Pickles.CommandLine/Pickles.CommandLine.csproj -t -d license-files
