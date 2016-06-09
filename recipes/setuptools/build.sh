#!/bin/bash

$PYTHON setup.py install

cd $PREFIX/bin
rm "easy_install-$PY_VER"
ln -s easy_install "easy_install-$PY_VER"
