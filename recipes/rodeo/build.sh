#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record record.txt

if [ `uname` == Darwin ]
then
    cp $RECIPE_DIR/rodeo_mac.command $PREFIX/bin
fi
