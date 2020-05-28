#!/bin/bash -euo

set -x
set -o xtrace -o nounset -o pipefail -o errexit

SOEXT=so
if [ "$(uname)" == "Darwin" ]; then
    SOEXT=dylib
fi

export RUSTC_WRAPPER=$(which sccache)

$PYTHON -m pip install --no-deps --ignore-installed -vv .

cp include/sourmash.h ${PREFIX}/include/

cargo build --release
cp target/release/libsourmash.a ${PREFIX}/lib/
cp target/release/libsourmash.${SOEXT} ${PREFIX}/lib/

mkdir -p ${PREFIX}/lib/pkgconfig
cat > ${PREFIX}/lib/pkgconfig/sourmash.pc <<"EOF"
prefix=/usr/local
exec_prefix=${prefix}
includedir=${prefix}/include
libdir=${exec_prefix}/lib

Name: sourmash
Description: Compute MinHash signatures for nucleotide (DNA/RNA) and protein sequences.
Version: 0.7.0
Cflags: -I${includedir}
Libs: -L${libdir} -lsourmash
EOF
