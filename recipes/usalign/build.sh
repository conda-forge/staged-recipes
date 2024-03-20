#!/bin/bash

rm -f USalign

mv ${SRC_DIR}/USalign.cpp .

${CXX} ${CXXFLAGS} -o USalign USalign.cpp

cp USalign ${PREFIX}/bin/USalign
