#/bin/bash

set -ex

build_install_gnutool() {
    local tool=$1
    local version=$2
    local options=$3 || ''

    curl -sLO https://ftp.gnu.org/gnu/${tool}/${tool}-${version}.tar.gz
    tar zxf ${tool}-${version}.tar.gz
    (cd ${tool}-${version}; ./configure "${options}" --prefix=${SRC_DIR}/gnu-tools)
    (cd ${tool}-${version}; make)
    (cd ${tool}-${version}; make test)
    (cd ${tool}-${version}; make install)
    rm -rf ${tool}-${version}
}

build_dll() {
    ./autogen.sh
    ./configure --enable-module-recovery --enable-experimental --enable-module-ecdh --enable-module-extrakeys --enable-module-schnorrsig --enable-benchmark=no --enable-tests=no --enable-openssl-tests=no --enable-exhaustive-tests=no --enable-static --disable-dependency-tracking --with-pic
    make
}

mkdir -p /tmp

# Trying to resolve the autoreconf issue
mkdir -p ${SRC_DIR}/gnu-tools/bin
export PATH=${SRC_DIR}/gnu-tools/bin:${SRC_DIR}/gnu-tools/share:$PATH

build_install_gnutool "m4" "1.4.19" "--disable-dependency-tracking"
# In m4?: build_install_gnutool "autoconf" "2.71"
build_install_gnutool "automake" "1.16.5"
build_install_gnutool "libtool" "2.4.7"

# This may not be necessary to prevent corruption of SOURCES.txt with full-path
rm -rf coincurve.egg-info libsecp256k1

mv ${SRC_DIR}/coincurve/_windows_libsecp256k1.py ${SRC_DIR}/coincurve/_libsecp256k1.py

curl -sLO "https://github.com/bitcoin-core/secp256k1/archive/$COINCURVE_UPSTREAM_REF.tar.gz"
tar xzf "$COINCURVE_UPSTREAM_REF.tar.gz"
mv "secp256k1-$COINCURVE_UPSTREAM_REF" secp256k1

(cd secp256k1; build_dll; mv .libs/libsecp256k1-0.dll ../libsecp256k1.dll)

${PYTHON} setup.py bdist_wheel
