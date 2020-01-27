#!/bin/bash

set -e

python -m pip install --ignore-installed SigProfilerMatrixGenerator==1.0.25
python -m pip install --ignore-installed sigproextractor
# python -m pip3 install --ignore-installed sigProfilerPlotting

./sigprofiler -ig GRCh38
cp * ${PREFIX}/bin/
chmod u+rwx $PREFIX/bin/*
