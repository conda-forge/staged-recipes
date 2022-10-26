
set -o errexit -o pipefail

# Copied from Bioconda recipe. Ensure tests use the environment Perl.
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' t/*.t
sed -i.bak 's|perl -w|/usr/bin/env perl|' t/make_executable.t

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


