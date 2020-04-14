#!/bin/bash
set -e

# Rewrite make.inc to comply with conda build
cat << EOF > make.inc
LIBS = -lgsl -lgslcblas -ldistfit -lmsa -ldssplite -ldltmath -lDLTutils -ltheseus
SYSLIBS = -lpthread -lgsl -lgslcblas -lm -lc
LIBDIR = -L./lib
INSTALLDIR = ${PREFIX}/bin
RANLIB = ${RANLIB}
EOF

# ARCH defaults to "64" (bit) in conda-build, this should be AR!
sed -i.bak -e 's/\$(ARCH)/$(AR)/g' \
           -e 's/\$(ARCHFLAGS)/rvs/g' \
           Makefile lib*/Makefile

make && make install
