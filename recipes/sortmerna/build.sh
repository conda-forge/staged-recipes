#!/bin/bash
echo "running python setup.py -n all"
env
python setup.py -n all
mkdir -p $PREFIX/bin
cp -r $SRC_DIR/dist/bin/sortmerna $PREFIX/bin
