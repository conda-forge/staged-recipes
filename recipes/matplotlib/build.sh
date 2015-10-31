#!/bin/bash

# Remove the baseline test images, they are just too big.
rm -rf lib/matplotlib/tests/baseline_images/*

if [ `uname` == Linux ]; then
    pushd $PREFIX/lib
    ln -s libtcl8.5.so libtcl.so
    ln -s libtk8.5.so libtk.so
    popd
fi

if [ `uname` == Darwin ]; then
#    sed s:'#ifdef WITH_NEXT_FRAMEWORK':'#if 1':g -i src/_macosx.m

    # Disable the macos backend. It doesn't seem to build correctly with travis yet.
    sed -i.bak "s|#macosx = auto|macosx = false|" setup.cfg.template

    sed -i.bak "s|#tkagg = auto|tkagg = true|" setup.cfg.template
fi

cp setup.cfg.template setup.cfg || exit 1

sed -i.bak "s|/usr/local|$PREFIX|" setupext.py

$PYTHON setup.py install

rm -rf $SP_DIR/PySide
rm -rf $SP_DIR/__pycache__
rm -rf $PREFIX/bin/nose*

