#!/bin/bash

# Otherwise this picks up the wrong linker on Linux (in most cases the system C++ compiler)
if [ $(uname) == Linux ]; then
  export LDSHARED="$CC -shared -pthread"
fi
${PYTHON} setup.py build_ext -DUSE_SYSTEM_BLOSC2:BOOL=YES
