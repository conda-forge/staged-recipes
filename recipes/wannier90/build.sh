#!/bin/bash
cp ${RECIPE_DIR}/make.inc ${SRC_DIR}/make.inc
make wannier
make tests
make install PREFIX=${PREFIX}
