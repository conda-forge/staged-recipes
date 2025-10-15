#!/bin/bash
set -ex

echo "PREFIX"
echo $PREFIX
grep -rl 'leptonica/allheaders.h' . | xargs sed -i "s|#include <leptonica/allheaders.h>|#include \"${PREFIX}/include/leptonica/allheaders.h\"|"
./autogen.sh
./configure
make
make install PREFIX=${PREFIX}
