#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" \
    src/Facility.LanguageServer/Facility.LanguageServer.csproj
dotnet publish --no-self-contained src/Facility.LanguageServer/Facility.LanguageServer.csproj --output ${PREFIX}/libexec/${PKG_NAME}
rm ${PREFIX}/libexec/${PKG_NAME}/Facility.LanguageServer

# Create bash and batch wrappers
tee ${PREFIX}/bin/facility-language-server << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/facility-language-server/Facility.LanguageServer.dll "\$@"
EOF

tee ${PREFIX}/bin/facility-language-server.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\facility-language-server\Facility.LanguageServer.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
tee ignored_packages.json << EOF
["OmniSharp.Extensions.*"]
EOF
dotnet-project-licenses --input src/Facility.LanguageServer/Facility.LanguageServer.csproj -t -d license-files -ignore ignored_packages.json
