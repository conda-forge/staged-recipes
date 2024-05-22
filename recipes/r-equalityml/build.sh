#!/bin/bash
export DISABLE_AUTOBREW=1
cd equalityml-r/
${R} CMD INSTALL --build . ${R_ARGS}
