#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')

if [[ "${build_platform}" == "win-64" ]]; then
    DOTNET_HOME="${PREFIX}/dotnet"
else
    DOTNET_HOME="${PREFIX}/lib/dotnet"
fi

mkdir -p "${DOTNET_HOME}/shared"

cp ./dotnet/dotnet* "${DOTNET_HOME}"
cp -r ./dotnet/shared/Microsoft.NETCore.App/ "${DOTNET_HOME}/shared/Microsoft.NETCore.App/"
cp -r ./dotnet/host/ "${DOTNET_HOME}/host/"

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp -r "${RECIPE_DIR}/activate.d/" "${PREFIX}/etc/conda/"
cp -r "${RECIPE_DIR}/deactivate.d/" "${PREFIX}/etc/conda/"
