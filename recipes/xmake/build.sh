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

mkdir -p .conda_compiler_aliases

ln -sf "$(which ${CC})" .conda_compiler_aliases/cc
ln -sf "$(which ${CXX})" .conda_compiler_aliases/c++
ln -sf "$(which ${AR})" .conda_compiler_aliases/ar

export PATH="$(pwd)/.conda_compiler_aliases:${PATH}"

export CC="cc"
export CXX="c++"
export GXX="c++"
export GCC="cc"
export LD="c++"
export AR="ar"
export AS="cc"
export CPP="cc -E"
export CXXCPP="c++ -E"

./configure \
    --prefix="${PREFIX}" \
    --cc="cc" \
    --cxx="c++" \
    --ld="c++" \
    --ar="ar"

make -j"${CPU_COUNT:-1}"
make install PREFIX="${PREFIX}"
