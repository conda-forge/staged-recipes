#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
rm -rf dotnet-tools.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
sed -i 's/dotnet tool run //g' Source/DafnyCore/DafnyCore.csproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" Source/Dafny/Dafny.csproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" Source/DafnyCore/DafnyCore.csproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" Source/DafnyDriver/DafnyDriver.csproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" Source/DafnyLanguageServer/DafnyLanguageServer.csproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" Source/DafnyPipeline/DafnyPipeline.csproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" Source/DafnyServer/DafnyServer.csproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" Source/DafnyTestGeneration/DafnyTestGeneration.csproj

dotnet publish -maxcpucount:1 --no-self-contained Source/Dafny/Dafny.csproj --output ${PREFIX}/libexec/${PKG_NAME}
dotnet publish -maxcpucount:1 --no-self-contained Source/DafnyServer/DafnyServer.csproj --output ${PREFIX}/libexec/${PKG_NAME}
rm ${PREFIX}/libexec/${PKG_NAME}/Dafny
rm ${PREFIX}/libexec/${PKG_NAME}/DafnyDriver
rm ${PREFIX}/libexec/${PKG_NAME}/DafnyServer

# Create bash and batch wrappers
tee ${PREFIX}/bin/dafny << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/dafny/Dafny.dll "\$@"
EOF

tee ${PREFIX}/bin/dafny.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\dafny\Dafny.dll %*
EOF

tee ${PREFIX}/bin/DafnyServer << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/dafny/DafnyServer.dll "\$@"
EOF

tee ${PREFIX}/bin/DafnyServer.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\dafny\DafnyServer.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
tee ignored_packages.json << EOF
["Boogie.*", "Microsoft.TestPlatform.*", "OmniSharp.Extensions.*", "RangeTree"]
EOF
dotnet-project-licenses --input Source/Dafny/Dafny.csproj -t -d license-files -ignore ignored_packages.json
dotnet-project-licenses --input Source/DafnyServer/DafnyServer.csproj -t -d license-files -ignore ignored_packages.json
