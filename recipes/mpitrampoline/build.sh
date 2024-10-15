#!/bin/bash
cmake -B build -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build build
cmake --install build
