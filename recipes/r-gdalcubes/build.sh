#!/bin/bash
export DISABLE_AUTOBREW=1

sed -i.bak 's/${PROJ_LIBS}/${PROJ_LIBS} ${LDFLAGS}/g' configure
sed -i.bak 's/${LIBS}/${LIBS} ${LDFLAGS}/g' configure

${R} CMD INSTALL --build . ${R_ARGS}
