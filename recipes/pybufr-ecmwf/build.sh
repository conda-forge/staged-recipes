#!/bin/bash

if [ $(uname) == Darwin ]; then
  export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib
  export LDFLAGS="-undefined dynamic_lookup -bundle -Wl,-search_paths_first,$LDFLAGS"
fi


$PYTHON setup.py install
