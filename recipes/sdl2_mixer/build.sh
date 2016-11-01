#!/bin/bash
cd ${SRC_DIR}

./configure --disable-dependency-tracking --prefix=${PREFIX}
make install