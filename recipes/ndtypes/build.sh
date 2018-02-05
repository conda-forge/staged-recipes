#!/usr/bin/env sh

$PYTHON setup.py install || exit 1
cp python/*.py $RECIPE_DIR
