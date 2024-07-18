#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
dotnet publish --no-self-contained "source/Nuke.GlobalTool/Nuke.GlobalTool.csproj" --output ${PREFIX}/libexec/${PKG_NAME}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/Nuke.GlobalTool

# Create bash and batch wrappers
tee ${PREFIX}/bin/nuke << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/nuke/Nuke.GlobalTool.dll "\$@"
EOF

tee ${PREFIX}/bin/nuke.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\nuke\Nuke.GlobalTool.dll %*
EOF

# Download dependency licenses with dotnet-project-licenses
dotnet-project-licenses -e --input . -f license-files
