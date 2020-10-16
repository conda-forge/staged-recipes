#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')

if [[ "${build_platform}" == "win-64" ]]; then
    DOTNET_HOME="${PREFIX}/dotnet"
else
    DOTNET_HOME="${PREFIX}/lib/dotnet"
fi

mkdir -p "${DOTNET_HOME}"
cp -r ./dotnet/packs/ "${DOTNET_HOME}/packs/"
cp -r ./dotnet/sdk/ "${DOTNET_HOME}/sdk/"
cp -r ./dotnet/templates/ "${DOTNET_HOME}/templates/"
