#!/usr/bin/env sh

cd $RECIPE_DIR/.. || exit 1
$PYTHON setup.py install || exit 1
cp python/*.py $RECIPE_DIR
