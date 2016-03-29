#!/bin/sh

curl -O https://raw.githubusercontent.com/curl/curl/master/lib/mk-ca-bundle.pl
shasum -a 256 mk-ca-bundle.pl |
    awk '$1=="6fbdd1c76a41b7ab41cd616b19e52522e2b7efb636120950f053ef2c22de44af"{print "mk-ca-bundle downloaded OK"}'
if [ $? -neq 0 ]; then
    echo "mk-ca-bundle did not pass checksum verification.  Has it changed at cURL's source?"
    exit 1
fi

perl mk-ca-bundle.pl

mkdir -p $PREFIX/etc/ssl/certs && cp ca-bundle.crt $PREFIX/etc/ssl/certs/ca-certificates.crt  # Debian/Ubuntu/Gentoo etc.
mkdir -p $PREFIX/etc/pki/tls/certs && cp ca-bundle.crt $PREFIX/etc/pki/tls/certs/ca-bundle.crt   # Fedora/RHEL
mkdir -p $PREFIX/etc/ssl && cp ca-bundle.crt $PREFIX/etc/ssl/ca-bundle.pem             # OpenSUSE
mkdir -p $PREFIX/etc/pki/tls && cp ca-bundle.crt $PREFIX/etc/pki/tls/cacert.pem            # OpenELEC
