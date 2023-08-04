#!/bin/bash

set -o errexit -o pipefail

perl Makefile.PL INSTALLDIRS=site \
    INC="-I${BUILD_PREFIX}/include" LIBS="-L${BUILD_PREFIX}/lib -lz"
make
make test
make install

mkdir -p $PREFIX/lib/perl5/5.32/site_perl
cp -R $BUILD_PREFIX/lib/perl5/5.32/site_perl/* $PREFIX/lib/perl5/5.32/site_perl/
