#!/bin/bash
export MACOSX_DEPLOYMENT_TARGET=10.13

git clone https://github.com/xtensor-stack/xtensor-fftw extern/xtensor-fftw
git clone https://github.com/kfrlib/kfr extern/kfr

NOISEFLOW_USE_CPP=1 ${PYTHON} -m pip install . --no-deps --ignore-installed -vvv

