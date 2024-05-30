#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $PREFIX/bin

cd $SRC_DIR
cp fgbio*.jar $outdir/fgbio.jar

cp $RECIPE_DIR/fgbio.py ${PREFIX}/bin/fgbio
chmod +x ${PREFIX}/bin/fgbio
