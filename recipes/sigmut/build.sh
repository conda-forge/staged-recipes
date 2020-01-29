#!/bin/bash

set -e
#./sigprofiler -ig GRCh38
./sigprofiler -h
conda --version
conda-build --version
echo "foobar"
cp -r * ${PREFIX}/bin/
chmod u+rwx $PREFIX/bin/*
