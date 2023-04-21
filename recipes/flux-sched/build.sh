#!/bin/bash
./configure --prefix=${PREFIX} \
    --with-boost-system=boost_system \
    --with-boost-filesystem=boost_filesystem \
    --with-boost-graph=boost_graph \
    --with-boost-regex=boost_regex
make
make check
make install
