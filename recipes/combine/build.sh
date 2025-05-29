#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Remove outdated autoconf/automake macros
sed -i '/AM_C_PROTOTYPES/d' configure.ac
sed -i '/AUTOMAKE_OPTIONS = ansi2knr/d' src/Makefile.am
sed -i '/AUTOMAKE_OPTIONS = ansi2knr/d' src/combine_scm/Makefile.am
sed -i '/@include fdl.texi/d' doc/combine.texinfo

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration -Wno-implicit-int"
export INFOPATH="${SRC_DIR}/doc"
autoreconf --force --verbose --install
./configure --disable-silent-rules \
    --disable-dependency-tracking \
    --prefix=${PREFIX}
make
make check
make install
