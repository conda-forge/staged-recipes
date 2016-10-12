#!/bin/bash

mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX

cmake --build . --config Release --target install
