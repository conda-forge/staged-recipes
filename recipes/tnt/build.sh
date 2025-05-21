#!/usr/bin/env bash

# This only has headers

INC_DIR=${PREFIX}/include/tnt
mkdir -p ${INC_DIR}
cp -fv * ${INC_DIR}
