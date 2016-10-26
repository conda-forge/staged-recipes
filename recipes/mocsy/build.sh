#!/bin/bash

make

rm -rf $SP_DIR/numpy
mkdir -p $SP_DIR/mocsy
cp mocsy*.so $SP_DIR/mocsy
