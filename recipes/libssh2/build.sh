#!/bin/bash

mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX

cmake --build . --config Release --target install
ctest -VV -C Release --output-on-failure
cmake --build . --config Release --target test
