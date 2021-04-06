#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')

if [[ "${build_platform}" == "win-64" ]]; then
    DOTNET_ROOT="${PREFIX}/dotnet"
else
    DOTNET_ROOT="${PREFIX}/lib/dotnet"
fi

METAMORPHEUS_ROOT=$DOTNET_ROOT/tools/metamorpheus

mkdir -p $PREFIX/bin $METAMORPHEUS_ROOT
cp -r $SRC_DIR/* $METAMORPHEUS_ROOT

if [[ "${build_platform}" == "win-64" ]]; then
    cp $RECIPE_DIR/metamorpheus.cmd $PREFIX/bin/metamorpheus.cmd
else
    cp $RECIPE_DIR/metamorpheus $PREFIX/bin/metamorpheus
    chmod +x $PREFIX/bin/metamorpheus
fi

