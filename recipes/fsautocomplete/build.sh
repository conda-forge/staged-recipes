#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"

# Overwrite hardcoded .NET version
sed -i "s?<TargetFrameworks>.*</TargetFrameworks>?<TargetFrameworks>net${framework_version}</TargetFrameworks>?" \
    src/FsAutoComplete/FsAutoComplete.fsproj
sed -i "/TargetFrameworks Condition/d" src/FsAutoComplete/FsAutoComplete.fsproj

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/libexec/${PKG_NAME}"

# Build package with dotnet publish
dotnet publish --no-self-contained src/FsAutoComplete/FsAutoComplete.fsproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}

# Create bash and batch wrappers
tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
exec \${DOTNET_ROOT}\dotnet exec \${CONDA_PREFIX}/libexec/fsautocomplete/fsautocomplete.dll "\$@"
EOF

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\fsautocomplete\fsautocomplete.dll %*
EOF

# Download dependency licneses with dotnet-project-licenses
dotnet-project-licenses -e --input . -f license-files
