#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Build each tool with dotnet publish
build() {
    bin_name=$1
    dotnet publish --no-self-contained src/Tools/${bin_name}/${bin_name}.csproj --output ${PREFIX}/libexec/${PKG_NAME}
    rm ${PREFIX}/libexec/${PKG_NAME}/${bin_name}
}

export -f build

# Crate bash and batch wrapper for each tool
env_script() {
bin_name=$1
tee ${PREFIX}/bin/${bin_name} << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/dotnet-diagnostics/${bin_name}.dll "\$@"
EOF

tee ${PREFIX}/bin/${bin_name}.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\dotnet-diagnostics\\${bin_name}.dll %*
EOF
}

export -f env_script

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

jq 'del(.tool)' < global.json > global.json.new
rm -rf global.json
mv global.json.new global.json
tools=(dotnet-counters dotnet-dsrouter dotnet-dump dotnet-gcdump dotnet-sos dotnet-stack dotnet-trace)

# Call functions to build each tool,create wrappers
printf "%s\n" "${tools[@]}" | xargs -I % bash -c "build %"
printf "%s\n" "${tools[@]}" | xargs -I % bash -c "env_script %"
printf "%s\n" "${tools[@]}" | xargs -I % bash -c "dotnet-project-licenses --input src/Tools/%/%.csproj -t -d license-files"

rm -rf ${PREFIX}/libexec/${PKG_NAME}/shims
