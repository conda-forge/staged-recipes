#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')

mkdir $RECIPE_DIR/build/
cd $RECIPE_DIR/build/
cmake ../
make

