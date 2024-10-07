#!/usr/bin/env /bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-debug \
	--prefix=${PREFIX}
make -j${CPU_COUNT} install
