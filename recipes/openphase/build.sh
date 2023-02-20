#!/bin/bash
make SETTINGS="serial" CXX=${CXX} CXXFLAGS="${CXXFLAGS}"
make SETTINGS="mpi-parallel" CXXFLAGS="${CXXFLAGS}"
cp -r include/* ${PREFIX}/include
cp -r lib/* ${PREFIX}/lib
