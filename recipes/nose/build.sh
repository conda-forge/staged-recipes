#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

rm -rf $PREFIX/man
rm -rf $SP_DIR/man
rm -rf $SP_DIR/nose-*.egg/man
rm -f $PREFIX/bin/nosetests-*
