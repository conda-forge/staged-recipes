#!/bin/bash
./autogen.sh
./configure --disable-dependency-tracking --prefix=${PREFIX}
make install
