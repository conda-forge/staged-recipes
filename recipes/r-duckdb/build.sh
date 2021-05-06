#!/bin/bash

export DISABLE_AUTOBREW=1

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION

# unset macosx-version-min hardcoded in clang CPPFLAGS
export CPPFLAGS="$(echo ${CPPFLAGS:-} | sed -E 's@\-mmacosx\-version\-min=[^ ]*@@g')"
echo "CPPFLAGS=$CPPFLAGS"

${R} CMD INSTALL --build . ${R_ARGS}

