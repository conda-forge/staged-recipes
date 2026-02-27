#!/bin/bash
set -euxo pipefail

cd "${SRC_DIR}"

# Workaround for rattler-build source extraction issue
if [ ! -f configure ]; then
    SRC_CACHE=$(python3 -c "
import json
d = json.load(open('.source_info.json'))
print(d['source_cache'])
" 2>/dev/null || true)
    if [ -n "${SRC_CACHE}" ]; then
        TARBALL=$(find "${SRC_CACHE}" -name '*.tar.gz' -type f | head -1)
        if [ -n "${TARBALL}" ]; then
            tar xzf "${TARBALL}" --strip-components=1
        fi
    fi
fi

./configure \
    --prefix="${PREFIX}"

make -j"${CPU_COUNT:-1}"
make install PREFIX="${PREFIX}"
