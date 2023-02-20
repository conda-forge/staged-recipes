#!/bin/bash
make SETTINGS="serial mpi-parallel"
cp -r include/* ${PREFIX}/include
cp -r lib/* ${PREFIX}/lib
