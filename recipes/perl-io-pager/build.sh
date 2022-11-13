#!/bin/bash

set -o errexit -o pipefail

# Need to skip test 11-redirect-oo.t as $TERM is not set.
test_files='t/0*.t t/10-*.t t/12-*.t t/13-*.t t/14-*.t t/15-*.t t/16-*.t'

if [[ -f Build.PL ]]; then
    perl Build.PL
    perl ./Build
    perl ./Build test TEST_FILES="$test_files"
    perl ./Build install --installdirs vendor
elif [[ -f Makefile.PL ]]; then
    perl Makefile.PL INSTALLDIRS=vendor
    make
    make test TEST_FILES="$test_files"
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
