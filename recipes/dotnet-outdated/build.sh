#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained src/DotNetOutdated/DotNetOutdated.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework "net${framework_version}"
rm ${PREFIX}/libexec/${PKG_NAME}/dotnet-outdated

# Create bash and batch wrappers
tee ${PREFIX}/bin/dotnet-outdated << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/dotnet-outdated/dotnet-outdated.dll "\$@"
EOF

tee ${PREFIX}/bin/dotnet-outdated.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\dotnet-outdated\dotnet-outdated.dll %*
EOF

dotnet-project-licenses --input src/DotNetOutdated/DotNetOutdated.csproj -t -d license-files
