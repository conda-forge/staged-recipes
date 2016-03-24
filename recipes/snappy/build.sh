#!/bin/env bash


cp -r $RECIPE_DIR/autogen/* $SRC_DIR
./configure --prefix=$PREFIX
make
make check
make install

