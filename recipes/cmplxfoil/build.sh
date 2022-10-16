#!/bin/bash

cp config/defaults/config.LINUX_GFORTRAN.mk config/config.mk
make clean
make cmplxfoil_build
python -m pip install --no-deps --ignore-installed .
