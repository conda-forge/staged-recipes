#!/bin/bash


if [ "$(uname)" == "Darwin" ]
then
    # for Mac OSX
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
elif [ "$(uname)" == "Linux" ]
then
    # for Linux
    export LDFLAGS="${LDFLAGS} -Wl,-rpath=${PREFIX}/lib"
fi


./configure \
        --prefix="${PREFIX}" \
        --enable-shared \
        --enable-static \
        --with-pic \
        --with-apr="${PREFIX}" \
        --with-openssl="${PREFIX}" \
        --with-crypto="${PREFIX}" \
        --without-nss \
        --without-lber \
        --without-ldap \
        --without-gdbm \
        --without-ndbm \
        --without-berkeley-db \
        --without-pgsql \
        --without-mysql \
        --without-sqlite2 \
        --with-sqlite3="${PREFIX}" \
        --without-oracle \
        --without-freetds \
        --without-odbc \
        --with-expat="${PREFIX}" \
        --with-iconv="${PREFIX}" \

make

#
# Seem to be some linkage problems
# that are messing up our ability to
# run the test suite.
#
#make check

make install
