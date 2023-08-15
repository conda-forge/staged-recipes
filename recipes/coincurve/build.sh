#!/bin/bash

build_install_gnutool() {
    local tool=$1
    local version=$2
    local options=$3 || ''

    curl -sLO https://ftp.gnu.org/gnu/${tool}/${tool}-${version}.tar.gz
    tar zxf ${tool}-${version}.tar.gz
    (cd $(tar ztf ${tool}-${version}.tar.gz | head -n 1 | sed 's@/.*@@'); ./configure ${options} --prefix=$PWD/../gnu-tools; make; make install)
    (rm -rf $(tar ztf ${tool}-${version}.tar.gz | head -n 1 | sed 's@/.*@@'))
}

# Trying to resolve the autoreconf issue
mkdir -p gnu-tools/bin
export PATH=$PWD/gnu-tools/bin:$PATH

build_install_gnutool "m4" "latest" "--disable-dependency-tracking"
build_install_gnutool "autoconf" "latest"
build_install_gnutool "automake" "1.16.5"
build_install_gnutool "libtool" "2.4.7"

#curl -O https://ftp.gnu.org/gnu/m4/m4-latest.tar.gz
#curl -O https://ftp.gnu.org/gnu/m4/m4-latest.tar.gz.sig
#curl -O https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz
#curl -O https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz.sig
#curl -O https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.gz
#curl -O https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.gz.sig
#curl -O https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.gz
#curl -O https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.gz.sig

#curl -O https://ftp.gnu.org/gnu/gnu-keyring.gpg
#gpg --verify --keyring ./gnu-keyring.gpg m4-latest.tar.gz.sig m4-latest.tar.gz
#gpg --verify --keyring ./gnu-keyring.gpg autoconf-latest.tar.gz.sig autoconf-latest.tar.gz
#gpg --verify --keyring ./gnu-keyring.gpg automake-1.16.5.tar.gz.sig automake-1.16.5.tar.gz
#gpg --verify --keyring ./gnu-keyring.gpg libtool-2.4.7.tar.gz.sig libtool-2.4.7.tar.gz

#tar zxf m4-latest.tar.gz
#tar zxf autoconf-latest.tar.gz
#tar zxf automake-1.16.5.tar.gz
#tar zxf libtool-2.4.7.tar.gz

#(cd $(tar ztf m4-latest.tar.gz | head -n 1 | sed 's@/.*@@'); ./configure --disable-dependency-tracking --prefix=$PWD/../gnu-tools; make; make install)
#(cd $(tar ztf autoconf-latest.tar.gz | head -n 1 | sed 's@/.*@@'); ./configure --prefix=$PWD/../gnu-tools; make; make install)
#(cd $(tar ztf automake-1.16.5.tar.gz | head -n 1 | sed 's@/.*@@'); ./configure --prefix=$PWD/../gnu-tools; make; make install)
#(cd $(tar ztf libtool-2.4.7.tar.gz | head -n 1 | sed 's@/.*@@'); ./configure --prefix=$PWD/../gnu-tools; make; make install)

# This does not seem to work: python3 -m build --sdist .
${PYTHON} -m pip install --use-pep517 . -vvv .

