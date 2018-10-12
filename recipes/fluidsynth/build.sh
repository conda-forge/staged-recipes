#!/bin/bash

mkdir build
cd build
cmake .. -Denable-framework=OFF -DLIB_SUFFIX="" -Denable-libsndfile=ON -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_PREFIX_PATH:PATH=$PREFIX
make install
