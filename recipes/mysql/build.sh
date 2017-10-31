#!/bin/bash

# this script is based off the homebrew package:
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/mysql.rb

mkdir -p build
cd build

# -DINSTALL_* are relatiove to -DCMAKE_INSTALL_PREFIX
mkdir -p ${PREFIX}/mysql
cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DMYSQL_DATADIR=${PREFIX}/mysql/datadir \
    -DINSTALL_INCLUDEDIR=include/mysql \
    -DINSTALL_MANDIR=share/man \
    -DINSTALL_DOCDIR=share/doc/mysql \
    -DINSTALL_DOCREADMEDIR=mysql \
    -DINSTALL_INFODIR=share/info \
    -DINSTALL_MYSQLSHAREDIR=share/mysql \
    -DINSTALL_SUPPORTFILESDIR=mysql/support-files \
    -DINSTALL_SCRIPTDIR=mysql/scripts \
    -DSYSCONFDIR=${PREFIX}/etc \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_FIND_FRAMEWORK=LAST \
    -DCMAKE_VERBOSE_MAKEFILE=OFF \
    -Wno-dev \
    -DWITH_UNIT_TESTS=OFF \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci \
    -DCOMPILATION_COMMENT=conda-forge \
    -DWITH_SSL=bundled \
    -DWITH_EDITLINE=bundled \
    -DWITH_READLINE=bundled \
    -DWITH_BOOST=boost \
    -DDOWNLOAD_BOOST=1 \
    .. &> cmake.log

# make sure we can find cpp on the linux CI service
sed -i 's|= rpcgen|= rpcgen -Y /usr/bin|' */Makefile

make
make install &> install.log

# remove this dir so we do not ship it
rm -rf ${PREFIX}/mysql-test

# Make a symlink to script to start the server directly.
ln -s ${PREFIX}/mysql/support-files/mysql.server ${PREFIX}/bin/mysql.server
