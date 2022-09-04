#!/bin/bash
set -e

echo "**************** M U M P S  B U I L D  S T A R T S  H E R E ****************"

export LIBPATH="$PREFIX/metis-aster/lib $PREFIX/mumps-aster/lib $PREFIX/lib $LIBPATH"
export INCLUDES="$PREFIX/metis-aster/include $PREFIX/include $INCLUDES"
#export FCFLAGS="-Wno-argument-mismatch $FCFLAGS"
echo $PY_VER
cp -f $RECIPE_DIR/waf-2.0.24 ./waf # To solve the StopIteration issue see https://www.code-aster.org/forum2/viewtopic.php?id=24617
python3 waf configure install --prefix=${PREFIX}/mumps-aster --enable-metis --embed-metis --enable-scotch

echo "**************** M U M P S  B U I L D  E N D S  H E R E ****************"