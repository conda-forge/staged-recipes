#!/bin/sh

mkdir -p $PREFIX/lib/vega-cli
cd $PREFIX/lib/vega-cli
yarn add vega-cli@$PKG_VERSION

cd $PREFIX/bin
for cmd in vg2pdf vg2png vg2svg
do
    ln -s ../lib/vega-cli/node_modules/vega-cli/bin/$cmd .
done

cp $PREFIX/lib/vega-cli/node_modules/vega-cli/LICENSE $SRC_DIR
