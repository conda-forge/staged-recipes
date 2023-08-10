#!/bin/bash
set -euo pipefail

# Trying to resolve the autoreconf issue
wget https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz
wget https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz.sig
gpg --keyserver hkp://keys.openpgp.org --recv-keys 82F854F3CE73174B8B63174091FCC32B6769AA64
gpg --verify autoconf-latest.tar.gz.sig autoconf-latest.tar.gz

tar zxf autoconf-latest.tar.gz
(cd autoconf-2.71; ./configure; make)
export PATH=$PATH:./autoconf-2.71

python setup.py bdist_egg
python setup.py egg_info

python setup.py build_clib

python setup.py install_lib

