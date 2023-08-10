#!/bin/bash
set -euo pipefail

# Trying to resolve the autoreconf issue
wget https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz
wget https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz.sig
wget https://ftp.gnu.org/gnu/gnu-keyring.gpg
gpg --verify --keyring ./gnu-keyring.gpg autoconf-latest.tar.gz.sig autoconf-latest.tar.gz

tar zxf autoconf-latest.tar.gz
(cd autoconf-2.71; ./configure; make)
export PATH=$PATH:./autoconf-2.71

python setup.py bdist_egg
python setup.py egg_info

python setup.py build_clib

python setup.py install_lib

