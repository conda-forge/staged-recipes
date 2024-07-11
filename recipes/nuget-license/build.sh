#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}

#Overwrite hardcoded dotnet version
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
sed -i "s/net7.0/net${framework_version}/" src/NugetUtility.csproj

# Build package with dotnet build
dotnet publish --no-self-contained src/NugetUtility.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}

mkdir -p ${PREFIX}/bin
rm -rf ${PREFIX}/libexec/${PKG_NAME}/NugetUtility

# Create bash and batch wrappers for dotnet-project-licenses
tee ${PREFIX}/bin/dotnet-project-licenses << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet exec ${PREFIX}/libexec/${PKG_NAME}/NugetUtility.dll "\$@"
EOF

tee ${PREFIX}/bin/dotnet-project-licenses.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\nuget-license\NugetUtility.dll %*
EOF

# Use newly build dotnet-project-licenses to get dependency licenses for this project.
chmod +x ${PREFIX}/bin/dotnet-project-licenses
${PREFIX}/bin/dotnet-project-licenses -e --input . -f license-files
