#!/bin/bash

cd configure
$PYTHON -c "from lib2to3.main import main;main('lib2to3.fixes')" -w configure.py
mkdir -p $PREFIX/lib/qt4/bin
ln -s $PREFIX/bin/qmake $PREFIX/lib/qt4/bin/qmake
ln -s $PREFIX/include/qt $PREFIX/include/qt4
$PYTHON configure.py -Q ../qwt-5.2 --disable-numarray --disable-numeric --qt4 --disable-numpy

make -j$CPU_COUNT
make install
