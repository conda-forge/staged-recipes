#!/bin/bash
cmake -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% \
.

make
make install
