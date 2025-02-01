#!/bin/bash
cmake -B build --preset conda_raspa3 -DCMAKE_INSTALL_PREFIX=${PREFIX}
ninja -C build install
