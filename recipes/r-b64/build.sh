#!/bin/bash
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS} || (ls -l ./rust/target; exit 1)
