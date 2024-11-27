#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
sed -i "s?<TargetFrameworks>.*</TargetFrameworks>?<TargetFrameworks>net${framework_version}</TargetFrameworks>?" Coco.csproj
dotnet publish --no-self-contained Coco.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework "net${framework_version}"
rm ${PREFIX}/libexec/${PKG_NAME}/Coco

# Create bash and batch wrappers
tee ${PREFIX}/bin/coco << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/coco/Coco.dll "\$@"
EOF

tee ${PREFIX}/bin/coco.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\coco\Coco.dll %*
EOF
