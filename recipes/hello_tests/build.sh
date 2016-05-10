#!/bin/bash

# A temporary hack.
source activate _build

export CXXFLAGS="${CXXFLAGS} -std=c++11"
export LDFLAGS="${LDFLAGS} -std=c++11"

${CXX} ${CXXFLAGS} ${LDFLAGS} hello.cxx

mkdir -p "${PREFIX}/bin"
mv a.out "${PREFIX}/bin/hello"
