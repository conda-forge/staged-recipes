#!/bin/bash

# this script is based off the homebrew package:
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/mysql.rb

echo `which cpp`
ln -s `which cpp` /lib/cpp
ln -s `which cpp` /usr/bin/cpp
ln -s `which cpp` /lib64/cpp

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
    -DCMAKE_VERBOSE_MAKEFILE=ON \
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
    ..

make
make install

# we will run this test now and then delete the directory
# there is no reason to ship the test dir and it is big
cd ${PREFIX}/mysql-test
mysql_temp_dir=`mktemp -d`
# the || here is a rough try...except
./mysql-test-run.pl status --vardir=${mysql_temp_dir} || rm -rf ${mysql_temp_dir}
# always delete anything left
rm -rf ${mysql_temp_dir}
cd -
rm -rf ${PREFIX}/mysql-test

# install a default config
echo "[mysqld]
bind-address = 127.0.0.1
" > ${PREFIX}/etc/my.cnf
