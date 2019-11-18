#!/bin/bash

set -e
set -x

export OMP_NUM_THREADS=1

echo "Testing Serial build"

python -c 'import toast.tests; toast.tests.run()'
