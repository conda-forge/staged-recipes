#!/bin/bash

export DISABLE_AUTOBREW=1

mv DESCRIPTION DESCRIPTION.old
grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION
${R} CMD INSTALL --build . ${R_ARGS}
${R} CMD INSTALL --with-libpng-prefix=/usr/X11/lib/ rgl ${R_ARGS}


