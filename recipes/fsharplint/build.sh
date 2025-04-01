#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/fsharplint
ln -sf ${DOTNET_ROOT}/dotnet ${PREFIX}/bin

rm -rf global.json
rm -rf paket.lock
rm -rf .paket
rm -rf .config/dotnet-tools.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"

# Use .net 8.0 instead of 6.0
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" \
    src/FSharpLint.Console/FSharpLint.Console.fsproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" \
    src/FSharpLint.Core/FSharpLint.Core.fsproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" \
    tests/FSharpLint.Benchmarks/FSharpLint.Benchmarks.fsproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" \
    tests/FSharpLint.Console.Tests/FSharpLint.Console.Tests.fsproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" \
    tests/FSharpLint.Core.Tests/FSharpLint.Core.Tests.fsproj
sed -i "s?<TargetFramework>.*</TargetFramework>?<TargetFramework>net${framework_version}</TargetFramework>?" \
    tests/FSharpLint.FunctionalTest/FSharpLint.FunctionalTest.fsproj
sed -i "s/net[0-9]*.0/net${framework_version}/g" paket.dependencies

# Apply fix from https://github.com/fsprojects/FSharpLint/pull/716 for .NET 8.0 support
sed -i 's/getRemainingGlobSeqForMatches pathSegment/getRemainingGlobSeqForMatches (pathSegment:string)/' src/FSharpLint.Core/Application/Configuration.fs

paket install
dotnet publish --no-self-contained src/FSharpLint.Console/FSharpLint.Console.fsproj --output ${PREFIX}/libexec/fsharplint --framework net${framework_version}
rm -rf ${PREFIX}/libexec/fsharplint/dotnet-fsharplint

tee ${PREFIX}/bin/dotnet-fsharplint << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/fsharplint/dotnet-fsharplint.dll "\$@"
EOF
chmod +x ${PREFIX}/bin/dotnet-fsharplint

# Download dependency licenses with dotnet-project-licenses
tee ignored_packages.json << EOF
["SemanticVersioning", "FSharp.Control.Reactive"]
EOF
dotnet-project-licenses --input src/FSharpLint.Console/FSharpLint.Console.fsproj -t -d license-files -ignore ignored_packages.json

rm ${PREFIX}/bin/dotnet
