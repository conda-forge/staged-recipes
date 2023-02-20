#!/bin/bash
make SETTINGS="serial"
make SETTINGS="mpi-parallel"
cp -r include/* ${PREFIX}/include
cp -r lib/* ${PREFIX}/lib
