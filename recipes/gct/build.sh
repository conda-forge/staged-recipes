#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Workaround from: https://github.com/gridcf/gct/issues/79#issuecomment-486323795
( cd gsi_openssh/source; aclocal; autoheader; autoconf )

# Fix up the shebangs to use conda's perl
grep -rlE '/usr/bin/perl' . | xargs -I _ sed -i.bak '1s@/usr/bin/perl@/usr/bin/env perl@' _

./configure \
    --prefix="${PREFIX}" \
    --includedir="${PREFIX}/include/globus" \
    --libexecdir="${PREFIX}/share/globus"

make -j${CPU_COUNT}
make install
