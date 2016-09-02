#!/bin/bash

BP=$SP_DIR/datreant
mkdir $BP
cp $RECIPE_DIR/__init__.py $BP/
$PYTHON -c "import datreant"
