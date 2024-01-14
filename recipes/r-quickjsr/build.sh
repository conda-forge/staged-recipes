#!/bin/bash

## use gnu11
sed -ie 's/-std=c11/-std=gnu11/g' src/Makevars

export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS}
