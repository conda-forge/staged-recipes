#!/bin/bash

$PYTHON -m pip install $SRC_DIR -vv --no-deps --no-build-isolation
mkdir -p $PREFIX/bin
cp $SRC_DIR/esridump/esri2geojson.py $PREFIX/bin/esri2geojson
chmod +x $PREFIX/bin/esri2geojson

