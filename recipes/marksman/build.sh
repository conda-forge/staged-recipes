#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm global.json
dotnet publish --no-self-contained Marksman/Marksman.fsproj --output ${PREFIX}/libexec/${PKG_NAME}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/${PKG_NAME}

# Create bash and batch wrappers
tee ${PREFIX}/bin/marksman << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/marksman/marksman.dll "\$@"
EOF

tee ${PREFIX}/bin/marksman.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\marksman\marksman.dll %*
EOF

# Download dependency licenses with dotnet-project-licenses
tee ignored_packages.json << EOF
["FSharp.SystemCommandLine"]
EOF
dotnet-project-licenses --input Marksman/Marksman.fsproj -t -d license-files -ignore ignored_packages.json
