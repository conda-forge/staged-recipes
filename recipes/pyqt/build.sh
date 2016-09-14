#!/bin/bash

if [ `uname` == Linux ]; then
    export QMAKESPEC="linux-g++"

    # Add qt.conf to the right place in $SRC_DIR so that
    # configure.py can run correctly
    cp $PREFIX/bin/qt.conf $SRC_DIR
fi

if [ `uname` == Darwin ]; then
    export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib/

    # Add qt.conf to the right place in $SRC_DIR so that
    # configure.py can run correctly
    QTCONF_PLACE=$SRC_DIR/qtdirs.app/Contents/Resources
    mkdir -p $QTCONF_PLACE
    cp $PREFIX/bin/qt.conf $QTCONF_PLACE
fi

$PYTHON configure.py \
          --verbose \
          --confirm-license \
          --bindir=$PREFIX/bin \
          --destdir=$SP_DIR \
          --qmake=$PREFIX/bin/qmake

make
make install

rm -rf $SP_DIR/__pycache__
