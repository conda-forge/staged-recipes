#!/bin/bash

set -e

pip install SigProfilerMatrixGenerator==1.0.25
pip install sigproextractor
pip3 install sigProfilerPlotting

./sigprofiler -ig GRCh38
cp * ${PREFIX}/bin/
chmod u+rwx $PREFIX/bin/*
