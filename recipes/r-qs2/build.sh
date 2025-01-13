#!/bin/bash
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --configure-args="--with-simd=AVX2 --with-TBB" --build . ${R_ARGS}
