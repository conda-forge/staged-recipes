#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record record.txt

BIN=$PREFIX/bin

if [[ `uname` == Darwin ]]; then
    mv psyplot_gui/app/Psyplot.app $PREFIX/psyplotapp
    sed -i '' "s/0.01/$PKG_VERSION/" $PREFIX/psyplotapp/Contents/Info.plist

    AE=$PREFIX/psyplotapp/Contents/MacOS/run.sh

    chmod +x $AE

    POST_LINK=$BIN/.psyplot-gui-post-link.sh
    PRE_UNLINK=$BIN/.psyplot-gui-pre-unlink.sh
    cp $RECIPE_DIR/osx-post.sh $POST_LINK
    cp $RECIPE_DIR/osx-pre.sh $PRE_UNLINK
    chmod +x $POST_LINK $PRE_UNLINK

else # not Darwin
    rm -rf psyplot_gui/app/Psyplot.app
fi
