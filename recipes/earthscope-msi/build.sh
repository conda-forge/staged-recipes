#!/bin/bash
set -euxo pipefail

# Upstream bundles its own copy of libmseed and always builds+statically
# links it (top-level Makefile: `all: libmseed` then `make -C src`). We skip
# that entirely and build only src/, pointing it at the libmseed host
# package instead, so msi dynamically links the packaged library rather than
# vendoring a duplicate build of it.
#
# -DLIBMSEED_URL enables msi's own URL-related CLI code paths (see msi.c);
# the packaged libmseed is also built with URL support, so the two agree.
# EXTRACFLAGS/EXTRALDFLAGS override src/Makefile's hardcoded `../libmseed`
# paths (plain `=` assignments there, so they're overridable on the command
# line). No explicit libcurl link is needed: msi.c never calls libcurl
# directly, only libmseed does internally, and it carries that dependency
# itself.
make -C src \
  CC="${CC}" \
  CFLAGS="${CFLAGS} -O2 -DLIBMSEED_URL" \
  EXTRACFLAGS="-I${PREFIX}/include" \
  EXTRALDFLAGS="-L${PREFIX}/lib" \
  -j"${CPU_COUNT}"

# Upstream has no install target; the binary is built at the repo root.
install -d "${PREFIX}/bin"
install -m 0755 msi "${PREFIX}/bin/msi"
