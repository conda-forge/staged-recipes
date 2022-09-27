#!/bin/bash
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build --configure-vars='INCLUDE_DIR=$INCLUDE LIB_DIR=$LIB' .
