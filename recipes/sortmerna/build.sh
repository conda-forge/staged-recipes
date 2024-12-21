#!/bin/bash
python setup.py -n all
mkdir -p $PREFIX/bin
cp -r $SRC_DIR/dist/bin/sortmerna $PREFIX/bin
