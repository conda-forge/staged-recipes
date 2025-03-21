#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${DOTNET_ROOT}/dotnet ${PREFIX}/bin

# Build package with dotnet publish
cp global.json global.json_old
jq 'del(.sdk)' global.json_old | jq 'del(.tools)' > global.json

rm -rf ${SRC_DIR}/src/polyglot-notebooks-browser/src/polyglot-notebooks
ln -sf ${SRC_DIR}/src/polyglot-notebooks/src ${SRC_DIR}/src/polyglot-notebooks-browser/src/polyglot-notebooks

pushd ${SRC_DIR}/src/polyglot-notebooks
npm ci
npm run compile
popd
pushd ${SRC_DIR}/src/polyglot-notebooks-browser
npm ci
npm run compile
popd

dotnet publish --no-self-contained src/dotnet-interactive/dotnet-interactive.csproj --output ${PREFIX}/libexec/${PKG_NAME}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/runtimes
rm -rf ${PREFIX}/libexec/${PKG_NAME}/Microsoft.DotNet.Interactive.App
rm ${PREFIX}/bin/dotnet

tee ignored_packages.json << EOF
["AsyncIO", "Json.More.Net", "JsonPointer.Net","Microsoft.DotNet.PlatformAbstractions", "Microsoft.Management.Infrastructure.Runtime.Win"]
EOF
dotnet-project-licenses --input src/dotnet-interactive/dotnet-interactive.csproj -t -d license-files -ignore ignored_packages.json

# Create bash and batch wrappers
tee ${PREFIX}/bin/dotnet-interactive << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/dotnet-interactive/Microsoft.DotNet.Interactive.App.dll "\$@"
EOF
chmod +x ${PREFIX}/bin/dotnet-interactive

tee ${PREFIX}/bin/dotnet-interactive.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\dotnet-interactive\Microsoft.DotNet.Interactive.App.dll %*
EOF
