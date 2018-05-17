#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

cp $RECIPE_DIR/cate-cli $PREFIX/bin/
chmod 775 $PREFIX/bin/cate-cli

if [ `uname` == Darwin ]
then
    cp -r $RECIPE_DIR/cate-cli.app $PREFIX/bin/
    sed -i -e "s,\${PKG_VERSION},${PKG_VERSION},g" "${PREFIX}/bin/cate-cli.app/Contents/Info.plist"
    chmod 775 "${PREFIX}/bin/cate-cli.app/Contents/MacOS/launch-cate-cli-in-terminal.sh"
else
    mkdir -p  $PREFIX/share/cate
    cp $RECIPE_DIR/cate.desktop-template $PREFIX/share/cate/
    cp $RECIPE_DIR/cate.png $PREFIX/share/cate/
fi
