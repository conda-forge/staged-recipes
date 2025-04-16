#!/bin/bash
sed -i 's/-mmacosx-version-min=10.13//g' ${PREFIX}/lib/R/etc/Makeconf
export PKG_CPPFLAGS='-D_LIBCPP_DISABLE_AVAILABILITY'
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS}
