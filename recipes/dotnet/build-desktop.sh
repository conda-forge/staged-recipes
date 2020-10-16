#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')

if [[ "${build_platform}" == "win-64" ]]; then
    DOTNET_HOME="${PREFIX}/dotnet"
else
    DOTNET_HOME="${PREFIX}/lib/dotnet"
fi

mkdir -p "${DOTNET_HOME}/shared"
cp -r ./dotnet/shared/Microsoft.WindowsDesktop.App/ "${DOTNET_HOME}/shared/Microsoft.WindowsDesktop.App/"
