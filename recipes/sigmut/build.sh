#!/bin/bash

set -e

python3 -m pip install SigProfilerMatrixGenerator==1.0.25
python3 -m pip install sigproextractor
python3 -m pip3 install sigProfilerPlotting

./sigprofiler -ig GRCh38
cp * ${PREFIX}/bin/
chmod u+rwx $PREFIX/bin/*
