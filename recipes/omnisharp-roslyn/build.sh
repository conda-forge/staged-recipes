#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"

# Override hardcoded .NET framework version
sed -i "s?<TargetFrameworks>.*</TargetFrameworks>?<TargetFrameworks>net${framework_version}</TargetFrameworks>?" \
    src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj
sed -i '/RuntimeFrameworkVersion/d;' src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj
sed -i '/RuntimeIdentifier/d;' src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/libexec/${PKG_NAME}"

# Build package with dotnet publish
dotnet publish --no-self-contained "src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj" \
    -maxcpucount:1 --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}
rm ${PREFIX}/libexec/${PKG_NAME}/OmniSharp

# Create bash and batch wrappers
tee ${PREFIX}/bin/OmniSharp << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/omnisharp/OmniSharp.dll "\$@"
EOF

tee ${PREFIX}/bin/OmniSharp.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\omnisharp\OmniSharp.dll %*
EOF

# Delete hidden file
rm test-assets/test-projects/ProjectWithWildcardPackageReference/._ProjectWithWildcardPackageReference.csproj

# Downlaod dependency licenses with dotnet-project-licenses
dotnet-project-licenses --input src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj -t -d license-files
