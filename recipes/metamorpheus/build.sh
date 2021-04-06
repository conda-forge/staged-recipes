#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')

mkdir -p $PREFIX/bin/tools
cp -r $SRC_DIR/* $PREFIX/bin

if [[ "${build_platform}" == "win-64" ]]; then
    mv $PREFIX/bin/CMD.exe $PREFIX/bin/metamorpheus.exe
else
    cp $RECIPE_DIR/metamorpheus $PREFIX/bin/tools/
    chmod +x $PREFIX/bin/tools/metamorpheus
fi

