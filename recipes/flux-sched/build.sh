#!/bin/bash
export LDFLAGS="${LDFLAGS} -lboost_system -lboost_graph -lboost_filesystem -lboost_regex"
export CXXFLAGS="${CXXFLAGS} -std=c++14 -Wno-maybe-uninitialized -I${PREFIX}/include -I${PREFIX}/include/boost"
./autogen.sh
./configure --prefix=${PREFIX} \
    --with-boost-system=boost_system \
    --with-boost-filesystem=boost_filesystem \
    --with-boost-graph=boost_graph \
    --with-boost-regex=boost_regex

make V=1

export FLUX_TESTS_LOGFILE=t
make check
make install
