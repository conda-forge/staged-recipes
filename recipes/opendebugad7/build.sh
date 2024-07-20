#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Override hardcoded .NET versions
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" \
    src/tools/MakePIAPortableTool/MakePIAPortableTool.csproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" \
    src/OpenDebugAD7/OpenDebugAD7.csproj

# Build package with dotnet build
dotnet build ${SRC_DIR}/src/MIDebugEngine-Unix.sln --configuration Release
dotnet publish --no-self-contained ${SRC_DIR}/src/OpenDebugAD7/OpenDebugAD7.csproj --configuration Release --output ${PREFIX}/libexec/${PKG_NAME}
rm -rf ${PREFIX}/libexec/opendebugad7/OpenDebugAD7

mkdir -p ${PREFIX}/bin

# Create bash and batch wrappers
tee ${PREFIX}/bin/OpenDebugAD7 << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/opendebugad7/OpenDebugAD7.dll "\$@"
EOF

tee ${PREFIX}/bin/OpenDebugAD7.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\opendebugad7\OpenDebugAD7.dll %*
EOF

# Download dependency licenses with dotnet-project-licenses
tee ignored_packages.json << EOF
["Microsoft.VisualStudio.Debugger.Interop*", "Microsoft.VisualStudio.Interop"]
EOF

dotnet-project-licenses --input ${SRC_DIR}/src/OpenDebugAD7/OpenDebugAD7.csproj -t -d license-files -ignore ignored_packages.json
