#!/bin/bash
cmake -B builddir -DBUILD_XTP=ON -DCMAKE_INSTALL_PREFIX=${PREFIX} votca
cmake --build builddir --parallel ${NUM_CPUS}
cmake --build builddir --target install
