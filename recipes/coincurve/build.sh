#!/bin/bash
set -euo pipefail

# Trying to resolve the autoreconf issue
wget https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz
wget https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz.sig
wget https://ftp.gnu.org/gnu/m4/m4-latest.tar.gz
wget https://ftp.gnu.org/gnu/m4/m4-latest.tar.gz.sig

wget https://ftp.gnu.org/gnu/gnu-keyring.gpg
gpg --verify --keyring ./gnu-keyring.gpg autoconf-latest.tar.gz.sig autoconf-latest.tar.gz
gpg --verify --keyring ./gnu-keyring.gpg m4-latest.tar.gz.sig m4-latest.tar.gz

tar zxf autoconf-latest.tar.gz
tar zxf m4-latest.tar.gz

(cd $(tar ztf m4-latest.tar.gz | head -n 1 | sed 's@/.*@@'); ./configure --prefix=$PWD/../gnu_tools --disable-dependency-tracking; make; make install)
export PATH=$PATH:./gnu_tools
(cd $(tar ztf autoconf-latest.tar.gz | head -n 1 | sed 's@/.*@@'); ./configure --prefix=$PWD/../gnu_tools; make; make install)

python setup.py bdist_egg
python setup.py egg_info

python setup.py build_clib

python setup.py install_lib

