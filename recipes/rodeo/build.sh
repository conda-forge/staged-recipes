#!/bin/bash

$PYTHON setup.py install

if [ `uname` == Darwin ]
then
    cp $RECIPE_DIR/rodeo_mac.command $PREFIX/bin
fi
