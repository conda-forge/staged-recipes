#!/bin/bash

export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export CPPFLAGS="${CXXFLAGS}"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"
export LIBS="$LIBS -lrdkafka -lz -lpthread -lrt"

python setup.py install --single-version-externally-managed --record record.txt
