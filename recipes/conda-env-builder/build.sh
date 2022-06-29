#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

# Development version build
# ./mill tools.localJar

# Release jar
cp jar/conda-env-builder*.jar $outdir/conda-env-builder.jar

cp $RECIPE_DIR/conda-env-builder.py ${PREFIX}/bin/conda-env-builder
chmod +x ${PREFIX}/bin/conda-env-builder
