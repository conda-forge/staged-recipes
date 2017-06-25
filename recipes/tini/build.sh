#!/bin/bash

mkdir build && cd build
cmake .. \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_PREFIX_PATH="${PREFIX}"
make
make install

####################################################
# We don't want tini statically link to GLIBC.     #
# So we just remove the static build. Have asked   #
# upstream for an option to disable the static     #
# build of tini.                                   #
#                                                  #
# xref: https://github.com/krallin/tini/issues/93  #
####################################################
rm "${PREFIX}/bin/tini-static"
