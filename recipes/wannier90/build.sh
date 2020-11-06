#!/bin/bash
cp ${RECIPE_DIR}/make.inc ${SRC_DIR}/make.inc
make wannier -j$CPU_COUNT
make test-serial -j$CPU_COUNT
make install PREFIX=${PREFIX}
