#!/bin/bash
set -euxo pipefail

cd build

# Install only the shared library and public header
install -Dm755 src/libamd_smi.so* -t "${PREFIX}/lib/"
install -Dm644 "${SRC_DIR}/include/amd_smi/amdsmi.h" "${PREFIX}/include/amd_smi/amdsmi.h"

# Create the expected symlinks
cd "${PREFIX}/lib"
SOVERSION=$(ls libamd_smi.so.* 2>/dev/null | grep -oP '\.so\.\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
MAJOR=$(echo "${SOVERSION}" | cut -d. -f1)
if [ -n "${SOVERSION}" ] && [ ! -L "libamd_smi.so" ]; then
    ln -sf "libamd_smi.so.${SOVERSION}" "libamd_smi.so.${MAJOR}"
    ln -sf "libamd_smi.so.${MAJOR}" "libamd_smi.so"
fi
