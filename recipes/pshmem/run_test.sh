#!/bin/bash

set -e
set -x

echo "Testing build"

MPI_DISABLE=1 python -c 'import pshmem.test; pshmem.test.run()'
