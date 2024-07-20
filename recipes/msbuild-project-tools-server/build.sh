#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
dotnet publish --no-self-contained src/LanguageServer/LanguageServer.csproj --output ${PREFIX}/libexec/${PKG_NAME}
rm ${PREFIX}/libexec/${PKG_NAME}/MSBuildProjectTools.LanguageServer.Host

# Create bash and batch wrappers
tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/msbuild-project-tools-server/MSBuildProjectTools.LanguageServer.Host.dll "\$@"
EOF

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\msbuild-project-tools-server\MSBuildProjectTools.LanguageServer.Host.dll %*
EOF

# Download dependency licenses with dotnet-project-licenses
tee ignored_packages.json << EOF
["OmniSharp.Extensions*"]
EOF
dotnet-project-licenses --input src/LanguageServer/LanguageServer.csproj -t -d license-files -ignore ignored_packages.json
