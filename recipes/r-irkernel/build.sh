#!/bin/bash

$R CMD INSTALL --build .

# This installs to the wrong place (/usr/local)
# $R -e "IRkernel::installspec(user=F)"

mkdir -p $PREFIX/share/jupyter/kernels/ir
cp inst/kernelspec/* $PREFIX/share/jupyter/kernels/ir/
