#!/usr/bin/env bash
set -euxo pipefail

export NIMBLE_DIR="${SRC_DIR}/.nimble"
mkdir -p "${NIMBLE_DIR}" "${PREFIX}/bin"

# Build the local package (fetches cligen/checksums into NIMBLE_DIR).
nimble build -y --nimbleDir:"${NIMBLE_DIR}"

install -m 755 bin/nimvault "${PREFIX}/bin/nimvault"
test -x "${PREFIX}/bin/nimvault"
