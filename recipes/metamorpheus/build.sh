#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')
METAMORPHEUS_ROOT=$DOTNET_ROOT/tools/metamorpheus

mkdir -p $METAMORPHEUS_ROOT
cp -r $SRC_DIR/* $METAMORPHEUS_ROOT

if [[ "${build_platform}" == "win-64" ]]; then
    cp $RECIPE_DIR/metamorpheus.cmd $PREFIX/bin
else
    cp $RECIPE_DIR/metamorpheus $PREFIX/bin
    chmod +x $PREFIX/bin/metamorpheus
fi

