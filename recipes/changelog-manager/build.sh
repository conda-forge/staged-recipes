#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained src/Credfeto.ChangeLog.Cmd/Credfeto.ChangeLog.Cmd.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework "net${framework_version}" /p:RunAnalyzers=False -c Release
ln -sf ${PREFIX}/libexec/${PKG_NAME}/Credfeto.ChangeLog.Cmd ${PREFIX}/bin/changelog
ln -sf ${PREFIX}/libexec/${PKG_NAME}/Credfeto.ChangeLog.Cmd ${PREFIX}/bin/changelog.cmd

# Download dependency licenses wtih dotnet-project-licenses
tee ignored_packages.json << EOF
["CommandLineParser", "Credfeto.Enumeration.Source.Generation*", "FunFair.CodeAnalysis", "LibGit2Sharp*", "Nullable.Extended.Analyzer"]
EOF
dotnet-project-licenses --input src/Credfeto.ChangeLog.Cmd/Credfeto.ChangeLog.Cmd.csproj -t -d license-files -ignore ignored_packages.json
