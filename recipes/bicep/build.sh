#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${DOTNET_ROOT}/dotnet ${PREFIX}/bin

# Build package with dotnet publish
rm -rf global.json
git remote set-url origin https://github.com/Azure/bicep

framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained src/Bicep.Cli/Bicep.Cli.csproj --output ${PREFIX}/libexec/${PKG_NAME} -p:PublishTrimmed=false -p:RestoreLockedMode=false
dotnet publish --no-self-contained src/Bicep.LangServer/Bicep.LangServer.csproj --output ${PREFIX}/libexec/${PKG_NAME}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/runtimes/*
rm -rf ${PREFIX}/libexec/${PKG_NAME}/bicep
rm -rf ${PREFIX}/libexec/${PKG_NAME}/Bicep.LangServer
cp ${SRC_DIR}/src/Bicep.Cli/bin/Release/net8.0/**/bicep.dll ${PREFIX}/libexec/${PKG_NAME}
cp ${SRC_DIR}/src/Bicep.Cli/bin/Release/net8.0/**/bicep.runtimeconfig.json ${PREFIX}/libexec/${PKG_NAME}

tee ignored_packages.json << EOF
["CommandLineParser", "Microsoft.AspNet.WebApi.Client", "Microsoft.Graph.Bicep.Types","OmniSharp.Extensions*"]
EOF
dotnet-project-licenses --input src/Bicep.Cli/Bicep.Cli.csproj -t -d license-files_bicep -ignore ignored_packages.json
dotnet-project-licenses --input src/Bicep.LangServer/Bicep.LangServer.csproj -t -d license-files_bicep-langserver -ignore ignored_packages.json
rm ${PREFIX}/bin/dotnet

# Create bash and batch wrappers
tee ${PREFIX}/bin/bicep << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/bicep/bicep.dll "\$@"
EOF
chmod +x ${PREFIX}/bin/bicep

tee ${PREFIX}/bin/bicep.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\bicep\bicep.dll %*
EOF

tee ${PREFIX}/bin/Bicep.LangServer << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/bicep/Bicep.LangServer.dll "\$@"
EOF
chmod +x ${PREFIX}/bin/Bicep.LangServer

tee ${PREFIX}/bin/Bicep.LangServer.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\bicep\Bicep.LangServer.dll %*
EOF
