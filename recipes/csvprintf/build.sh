#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ $target_platform =~ .*osx.* ]]; then
    export LDFLAGS="-liconv"
fi
./autogen.sh
./configure --disable-silent \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install LIBS="-L${PREFIX}/lib -liconv"
