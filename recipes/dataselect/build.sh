#!/bin/bash
set -euxo pipefail

# Use conda-forge libmseed instead of the vendored copy in libmseed/
rm -rf libmseed/

# The top-level Makefile descends into libmseed/, so call src/ directly.
# EXTRACFLAGS/EXTRALDFLAGS override the hardcoded ../libmseed paths in src/Makefile.
export CFLAGS="${CFLAGS} -DLIBMSEED_URL"
export LDFLAGS="${LDFLAGS} $(curl-config --libs)"

make -C src \
    EXTRACFLAGS="-I${PREFIX}/include" \
    EXTRALDFLAGS="-L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin" "${PREFIX}/share/man/man1"
install -m 755 dataselect "${PREFIX}/bin/dataselect"
install -m 644 doc/dataselect.1 "${PREFIX}/share/man/man1/dataselect.1"
