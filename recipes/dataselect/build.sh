#!/bin/bash
set -euxo pipefail

# Build the bundled libmseed and the dataselect binary.
# The top-level Makefile builds libmseed first, then src/, leaving the
# `dataselect` binary at the source-tree root.
make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"

# Upstream provides no install target ("copy the binary and man page as
# needed"), so install them by hand.
mkdir -p "${PREFIX}/bin" "${PREFIX}/share/man/man1"
install -m 755 dataselect "${PREFIX}/bin/dataselect"
install -m 644 doc/dataselect.1 "${PREFIX}/share/man/man1/dataselect.1"
