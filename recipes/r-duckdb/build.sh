#!/bin/bash

export DISABLE_AUTOBREW=1

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION

export MACOSX_VERSION_MIN="10.13"

${R} CMD INSTALL --build . ${R_ARGS}

