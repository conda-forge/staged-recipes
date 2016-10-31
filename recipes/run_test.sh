#!/bin/bash

cd $SRC_DIR/tests
mpirun -np 8 py.test
