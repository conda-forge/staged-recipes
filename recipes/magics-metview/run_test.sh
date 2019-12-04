#!/usr/bin/env bash

# This test script is only necessary when building with Metview enabled.
# Building with Metview enabled means we depend on Qt which means we depend on the GL
# system package for some shared libraries (e.g. libGL.so.1). We can add these libraries
# as test requirements using meta.yaml but in order to actually use them we need to modify
# LD_LIBRARY_PATH. At time of writing this doesn't appear to be possible from within
# meta.yaml, hence the addition of this script.

if [[ $(uname) == Linux ]]; then
    set -e # Abort on error
    echo Running test script.

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib64/

    echo import Magics
    python -c "import Magics"
    echo import Magics.macro
    python -c "import Magics.macro"
    echo import Magics.metgram
    python -c "import Magics.metgram"
    echo import Magics.toolbox
    python -c "import Magics.toolbox"
fi
