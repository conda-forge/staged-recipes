#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Delete vendored tool and build with dotnet publish
rm -rf global.json
rm -rf src/app/fake-cli/bin/Debug
dotnet tool restore
dotnet paket restore
dotnet publish --no-self-contained src/app/fake-cli/fake-cli.fsproj --output ${PREFIX}/libexec/${PKG_NAME}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/fake-cli

# Create bash and batch wrappers
tee ${PREFIX}/bin/fake-cli << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/fake/fake-cli.dll "\$@"
EOF

tee ${PREFIX}/bin/fake-cli.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\fake\fake-cli.dll %*
EOF

# Download dependency licenses with dotnet-project-licenses
dotnet-project-licenses --input src/app/fake-cli/fake-cli.fsproj -t -d license-files
