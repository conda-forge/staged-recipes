#!/usr/bin/env bash

set windows=
if [[ $OS == Windows* ]]; then
    windows=1
    export PATH=${LIBRARY_BIN}:$PATH
fi

script/build
chmod +x script/install.sh

export prefix=$PREFIX
if [ ! -z ${windows} ]; then
   cp bin/hub.exe $LIBRARY_BIN
else
   cp bin/hub $PREFIX/bin
fi
