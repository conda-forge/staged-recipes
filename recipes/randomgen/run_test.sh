#!/usr/bin/env bash

export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export QT_QPA_PLATFORM=offscreen
export MPLBACKEND=agg

python -c "import randomgen; randomgen.test(['--skip-slow'])"
