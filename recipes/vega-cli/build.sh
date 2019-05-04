#!/bin/sh

cd $PREFIX/lib
yarn add vega-cli@$PKG_VERSION

cd $PREFIX/bin
for cmd in vg2pdf vg2png vg2svg
do
    ln -s ../lib/node_modules/vega-cli/bin/$cmd .
done
