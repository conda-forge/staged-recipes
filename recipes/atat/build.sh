#!/bin/bash

mkdir atatbin
make -j3 
sed -i "s|BINDIR=\$(HOME)/bin/|BINDIR=${RECIPE_DIR}/atatbin|g" makefile
make install ${RECIPE_DIR}/atatbin
cp ${RECIPE_DIR}/atatbin/* ${PREFIX}/bin
cp -r data ${PREFIX}/atat_data
