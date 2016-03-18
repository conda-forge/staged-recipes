#!/bin/bash

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

# NO_TCLTK disables git-gui
# NO_PERL disables all perl-based utils:
#   git-instaweb, gitweb, git-cvsserver, git-svn
#   /ref http://www.spinics.net/lists/git/msg99803.html
# NO_GETTEXT disables internationalization (localized message translations)
# NO_INSTALL_HARDLINKS uses symlinks which makes the package 85MB slimmer (8MB instead of 93MB!)
make configure
./configure --prefix="${PREFIX}"
make \
    --jobs="$CPU_COUNT" \
    NO_TCLTK=1 \
    NO_PERL=1 \
    NO_GETTEXT=1 \
    NO_INSTALL_HARDLINKS=1 \
    all strip install
