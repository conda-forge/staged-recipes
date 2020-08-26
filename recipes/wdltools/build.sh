#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR

make
sbt assembly

cp target/wdlTools.jar $outdir/wdlTools.jar
cp $RECIPE_DIR/wdlTools.py ${PREFIX}/bin/wdltools
