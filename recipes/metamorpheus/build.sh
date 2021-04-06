#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')
METAMORPHEUS_ROOT=$DOTNET_ROOT/tools/metamorpheus

mkdir -p $METAMORPHEUS_ROOT
cp -r $SRC_DIR/* $METAMORPHEUS_ROOT

if [[ "${build_platform}" == "win-64" ]]; then
    mv $METAMORPHEUS_ROOT/CMD.exe $METAMORPHEUS_ROOT/metamorpheus.exe
else
    cp $RECIPE_DIR/metamorpheus $METAMORPHEUS_ROOT
    chmod +x $METAMORPHEUS_ROOT/metamorpheus
fi

