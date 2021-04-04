#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')

mkdir -p $PREFIX/bin
cp -r $SRC_DIR/* $PREFIX

if [[ "${build_platform}" == "win-64" ]]; then
    mv $PREFIX/CMD.exe $PREFIX/metamorpheus.exe
else
    cp $RECIPE_DIR/metamorpheus $PREFIX/metamorpheus
    chmod +x $PREFIX/metamorpheus
fi

