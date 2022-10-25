#!/bin/bash

set -o errexit -o pipefail

# Copied from BioConda recipe for perl-moose. Fixes error caused by wrong
# linker flags that need to be passed to LD via GCC, and not directly.
export LD="$CC"

if [[ -f Build.PL ]]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    perl ./Build install --installdirs vendor
elif [[ -f Makefile.PL ]]; then
    perl Makefile.PL INSTALLDIRS=vendor
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
