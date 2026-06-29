#!/bin/bash
set -euxo pipefail

# Build the bundled libmseed and the dataselect binary.
# The top-level Makefile builds libmseed first, then src/, leaving the
# `dataselect` binary at the source-tree root.
#
# Enable libmseed URL support and link the host libcurl. The flags MUST be set
# via the environment, not on the make command line: the Makefile enables URL
# support with `CFLAGS += -DLIBMSEED_URL` / `LDFLAGS += $(curl-config --libs)`,
# and GNU make ignores those `+=` appends when the variable is overridden on
# the command line (which would silently drop URL support and leave libcurl
# unlinked).
export CFLAGS="${CFLAGS} -DLIBMSEED_URL"
export LDFLAGS="${LDFLAGS} -lcurl"
make CC="${CC}"

# Upstream provides no install target ("copy the binary and man page as
# needed"), so install them by hand.
mkdir -p "${PREFIX}/bin" "${PREFIX}/share/man/man1"
install -m 755 dataselect "${PREFIX}/bin/dataselect"
install -m 644 doc/dataselect.1 "${PREFIX}/share/man/man1/dataselect.1"
