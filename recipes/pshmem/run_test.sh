#!/bin/bash

set -e
set -x

echo "Testing build"

python -c 'import pshmem.test; pshmem.test.run()'
