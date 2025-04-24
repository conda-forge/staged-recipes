#!/bin/bash
export DISABLE_AUTOBREW=1
export PKG_CPPFLAGS="-D_LIBCPP_DISABLE_AVAILABILITY ${PKG_CPPFLAGS}"

sed -i.bak 's/${PROJ_LIBS}/${PROJ_LIBS} ${LDFLAGS}/g' configure
sed -i.bak 's/${LIBS}/${LIBS} ${LDFLAGS}/g' configure

${R} CMD INSTALL --build . ${R_ARGS}
