#!/bin/bash
export RUSTFLAGS="-L${PREFIX}/lib ${RUSTFLAGS}"
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS}
