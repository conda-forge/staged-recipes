#!/bin/bash
set -euo pipefail

# Trying to resolve the autoreconf issue
wget https://ftp.gnu.org/gnu/m4/m4-latest.tar.gz
wget https://ftp.gnu.org/gnu/m4/m4-latest.tar.gz.sig
wget https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz
wget https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz.sig
wget https://ftp.gnu.org/gnu/automake/automake-latest.tar.gz
wget https://ftp.gnu.org/gnu/automake/automake-latest.tar.gz.sig

wget https://ftp.gnu.org/gnu/gnu-keyring.gpg
gpg --verify --keyring ./gnu-keyring.gpg m4-latest.tar.gz.sig m4-latest.tar.gz
gpg --verify --keyring ./gnu-keyring.gpg autoconf-latest.tar.gz.sig autoconf-latest.tar.gz
gpg --verify --keyring ./gnu-keyring.gpg automake-latest.tar.gz.sig automake-latest.tar.gz

tar zxf m4-latest.tar.gz
tar zxf autoconf-latest.tar.gz
tar zxf automake-latest.tar.gz

mkdir -p gnu-tools/bin
export PATH=$PWD/gnu-tools/bin:$PATH

(cd $(tar ztf m4-latest.tar.gz | head -n 1 | sed 's@/.*@@'); ./configure --disable-dependency-tracking --prefix=$PWD/../gnu-tools; make; make install)
(cd $(tar ztf autoconf-latest.tar.gz | head -n 1 | sed 's@/.*@@'); ./configure --prefix=$PWD/../gnu-tools; make; make install)
(cd $(tar ztf automake-latest.tar.gz | head -n 1 | sed 's@/.*@@'); ./configure --prefix=$PWD/../gnu-tools; make; make install)

python setup.py install

