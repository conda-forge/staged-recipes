#!/bin/bash

${CXX} -O3 -ffast-math -o USalign USalign.cpp

cp USalign ${PREFIX}/bin
