#!/bin/bash

rm -f USalign

${CXX} ${CXXFLAGS} -o USalign USalign.cpp
mkdir -p ${PREFIX}/bin #Make sure bin exists?
cp USalign ${PREFIX}/bin/USalign
