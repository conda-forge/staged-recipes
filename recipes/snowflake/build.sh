#!/bin/bash

BP=$SP_DIR/snowflake
mkdir $BP
cp $RECIPE_DIR/__init__.py $BP/
$PYTHON -c "import snowflake"

