#!/bin/bash
make SETTINGS="serial" CXX=${CXX}
make SETTINGS="mpi-parallel"
cp -r include/* ${PREFIX}/include
cp -r lib/* ${PREFIX}/lib
