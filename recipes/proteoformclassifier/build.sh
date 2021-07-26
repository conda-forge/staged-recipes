#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')

if [[ "${target_platform}" == "win-64" ]]; then
    DOTNET_ROOT="${PREFIX}/dotnet"
else
    DOTNET_ROOT="${PREFIX}/lib/dotnet"
fi

PROTEOFORMCLASSIFIER_ROOT=$DOTNET_ROOT/tools/proteoformclassifier

mkdir -p $PREFIX/bin $PROTEOFORMCLASSIFIER_ROOT
cp -r $SRC_DIR/* $PROTEOFORMCLASSIFIER_ROOT

if [[ "${target_platform}" == "win-64" ]]; then
    cp $RECIPE_DIR/proteoformclassifier.cmd $PREFIX/bin/proteoformclassifier.cmd
else
    cp $RECIPE_DIR/proteoformclassifier $PREFIX/bin/proteoformclassifier
    chmod +x $PREFIX/bin/proteoformclassifier
fi

