#!/bin/bash

set -e
set -x

export OMP_NUM_THREADS=1

echo "Testing MPICH build"

export HYDRA_LAUNCHER=fork

mpirun -np 2 python -c 'import toast.tests; toast.tests.run()'
