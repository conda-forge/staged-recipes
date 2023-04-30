#!/bin/bash
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --install-tests --build . ${R_ARGS}
