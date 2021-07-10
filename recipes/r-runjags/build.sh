#!/bin/bash
export DISABLE_AUTOBREW=1
rm configure
rm configure.ac
rm -rf src
${R} CMD INSTALL --build . ${R_ARGS}
