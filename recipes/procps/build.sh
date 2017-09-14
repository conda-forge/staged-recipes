#!/bin/bash
./autogen.sh
./configure --disable-debug --disable-dependency-tracking --disable-silent-rules --prefix=${PREFIX}
make install