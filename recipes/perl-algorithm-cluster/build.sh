#!/usr/bin/env bash

set -o errexit -o pipefail

perl Makefile.PL INSTALLDIRS=vendor NO_PERLLOCAL=1 NO_PACKLIST=1
make
make test
make install VERBINST=1
