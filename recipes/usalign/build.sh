#!/bin/bash

rm -f USalign

${CXX} -O3 -ffast-math -o USalign USalign.cpp

cp USalign ${PREFIX}/bin/USalign
