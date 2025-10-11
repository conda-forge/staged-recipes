#!/bin/bash

rm -f USalign

${CXX} -O3 -ffast-math -lm -o USalign USalign.cpp || ${CXX} ${CXXFLAGS} -o USalign USalign.cpp
mkdir -p ${PREFIX}/bin #Make sure bin exists?
cp USalign ${PREFIX}/bin/USalign
