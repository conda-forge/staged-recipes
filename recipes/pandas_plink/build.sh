#!/usr/bin/env bash

find / -name libffi.so.6

$FOLDER=`find / -name libffi.so.6 | tail -n 1 | xargs dirname`
export LD_LIBRARY_PATH=$FOLDER:$LD_LIBRARY_PATH

echo $FOLDER

$PYTHON setup.py install --single-version-externally-managed --record record.txt
