#!/bin/bash
set -euxo pipefail

# Enable libmseed URL support and link the host libcurl.
# Flags are set via the environment (not on the make command line) so the
# top-level Makefile's `CFLAGS := $(CFLAGS) ...` additions are preserved and
# propagated to both the libmseed and src sub-makes.
export CFLAGS="${CFLAGS} -DLIBMSEED_URL"
export LDFLAGS="${LDFLAGS} -lcurl"

make CC="${CC}" -j"${CPU_COUNT}"

# Upstream has no install target; the binary is built at the repo root.
install -d "${PREFIX}/bin"
install -m 0755 msi "${PREFIX}/bin/msi"
