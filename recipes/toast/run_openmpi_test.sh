#!/bin/bash

set -e
set -x

export OMP_NUM_THREADS=1

echo "Testing OpenMPI build"

mpirun --allow-run-as-root \
--mca btl self,tcp \
--mca plm isolated \
--mca rmaps_base_oversubscribe yes \
--mca btl_vader_single_copy_mechanism none \
-np 2 python -c 'import toast.tests; toast.tests.run()'
