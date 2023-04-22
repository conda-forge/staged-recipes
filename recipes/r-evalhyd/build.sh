#!/bin/bash

# make temporary directory
mkdir -p ${PREFIX}/tmp

export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS}
