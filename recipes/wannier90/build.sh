#!/bin/bash
cp ${RECIPE_DIR}/make.inc ${SRC_DIR}/make.inc
make wannier
make test-serial
make install
