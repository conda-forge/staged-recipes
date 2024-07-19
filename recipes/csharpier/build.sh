#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Update System.Text.Json to latest version to fix security warning
# Remove with next release
sed -i 's/"System.Text.Json" Version="7.0.3"/"System.Text.Json" Version="8.0.4"/' Directory.Packages.props

# Build package with dotnet publish
rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained Src/CSharpier.Cli/CSharpier.Cli.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}

# Create bash and batch wrappers
rm ${PREFIX}/libexec/${PKG_NAME}/dotnet-csharpier

tee ${PREFIX}/bin/dotnet-csharpier << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/csharpier/dotnet-csharpier.dll "\$@"
EOF

tee ${PREFIX}/bin/dotnet-csharpier.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX\libexec\csharpier\dotnet-csharpier.dll %*
EOF

# Download dependency licenses with dotnet-project-licenses
tee ignored_packages.json << EOF
["Ignore", "YamlDotNet"]
EOF

dotnet-project-licenses --input Src/CSharpier.Cli/CSharpier.Cli.csproj -t -d license-files -ignore ignored_packages.json
