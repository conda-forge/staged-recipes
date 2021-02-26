#!/bin/bash

# xml2-config add -lz and -llzma to the linker flags, resulting in overlinking
# only libxml2 needs to be linked
export LIBXML_LIBS="-lxml2"

./configure \
    --prefix=$PREFIX \
    --enable-shared \
    --enable-static=no \
    --disable-docs \
    --with-openssl="${PREFIX}" \
    --with-libxml="${PREFIX}" \
    --with-xslt="${PREFIX}" \
    --with-gcrypt="${PREFIX}"
make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install
