#!/bin/bash
set -euo pipefail


grep -rl 'leptonica/allheaders.h' . | while read -r file; do
  sed -i.bak "s|#include <leptonica/allheaders.h>|#include \"${PREFIX}/include/leptonica/allheaders.h\"|" "$file" && rm "$file.bak"
done

./autogen.sh
./configure
make
make install PREFIX=${PREFIX}
