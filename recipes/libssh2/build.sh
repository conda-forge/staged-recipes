#!/bin/bash

mkdir bin && cd bin
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX

cmake --build . --config Release --target install
