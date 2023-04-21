#!/bin/bash
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -I${PREFIX}/include/boost"
export LDFLAGS="${LDFLAGS} -lboost_system -lboost_graph -lboost_filesystem -lboost_regex"
./configure --prefix=${PREFIX} \
    --with-boost-system=boost_system \
    --with-boost-filesystem=boost_filesystem \
    --with-boost-graph=boost_graph \
    --with-boost-regex=boost_regex
make
make check
make install
