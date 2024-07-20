#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"

# Update System.Text.Json to newest version to fix security warning
# Remove with next release
sed -i "s/System.Text.Json (7.0.3)/System.Text.Json (8.0.4)/" paket.lock

# Overwrite hardcoded .NET version
sed -i "s?<TargetFrameworks>.*</TargetFrameworks>?<TargetFrameworks>net${framework_version}</TargetFrameworks>?" \
    src/FsAutoComplete/FsAutoComplete.fsproj
sed -i "/TargetFrameworks Condition/d" src/FsAutoComplete/FsAutoComplete.fsproj

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/libexec/${PKG_NAME}"

# Build package with dotnet publish
dotnet tool restore
dotnet publish --no-self-contained src/FsAutoComplete/FsAutoComplete.fsproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}

# Create bash and batch wrappers
tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/fsautocomplete/fsautocomplete.dll "\$@"
EOF

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\fsautocomplete\fsautocomplete.dll %*
EOF

# Download dependency licenses with dotnet-project-licenses
tee ignored_packages.json << EOF
["FSharp.Control.Reactive", "FSharp.UMX", "FsToolkit.*", "IcedTasks", "Ionide.KeepAChangelog.Tasks", "LinkDotNet.StringBuilder", "Microsoft.DotNet.PlatformAbstractions"]
EOF
dotnet-project-licenses --input src/FsAutoComplete/FsAutoComplete.fsproj -t -d license-files -ignore ignored_packages.json
