#!/bin/sh

mkdir -p $PREFIX/lib/vega-lite-cli
cd $PREFIX/lib/vega-lite-cli
yarn add vega-lite@$PKG_VERSION

cd $PREFIX/bin
for cmd in vl2pdf vl2png vl2svg vl2vg
do
    ln -s ../lib/vega-lite-cli/node_modules/vega-lite/bin/$cmd .
done

cp $PREFIX/lib/vega-lite-cli/node_modules/vega-lite/LICENSE $SRC_DIR
