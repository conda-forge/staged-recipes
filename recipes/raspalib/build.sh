#!/bin/bash
cmake -B build --preset conda_raspalib -DCMAKE_INSTALL_PREFIX=${PREFIX}
ninja -C build install
