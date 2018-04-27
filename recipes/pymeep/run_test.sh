#!/bin/bash

for t in python/tests/*.py; do
    echo "Running $(basename $t)"
    $PYTHON $t
done
