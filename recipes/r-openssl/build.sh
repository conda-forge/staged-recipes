#!/bin/bash

# Below variables overwrite hardcoded paths in configure script.
export INCLUDE_DIR=$PREFIX/include
export LIB_DIR=$PREFIX/lib

$R CMD INSTALL --build .
