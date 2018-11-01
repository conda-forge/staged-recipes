#!/bin/bash
set -e

export OMPI_MCA_plm=isolated
export OMPI_MCA_btl_vader_single_copy_mechanism=none
export OMPI_MCA_rmaps_base_oversubscribe=yes

python -c 'import mpi4py_fft'

pushd "tests"

TESTS="test_mpifft.py"

RUN_TESTS="python -b -m pytest -vs $TESTS"
# serial
$RUN_TESTS

# parallel
mpiexec -n 2 $RUN_TESTS 2>&1 </dev/null | cat
