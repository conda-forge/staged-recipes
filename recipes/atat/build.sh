#!/bin/bash

mkdir atatbin
sed -i "s|CXX=g++|CXX=${CXX}|g" makefile
sed -i "s|BINDIR=\$(HOME)/bin/|BINDIR=${RECIPE_DIR}/atatbin|g" makefile
make force
make install ${RECIPE_DIR}/atatbin
cp ${RECIPE_DIR}/atatbin/* ${PREFIX}/bin
cp -r data ${PREFIX}/atat_data
