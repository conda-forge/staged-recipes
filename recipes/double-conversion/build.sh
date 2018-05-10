#!/bin/bash

cmake . -DCMAKE_INSTALL_PREFIX=$PREFIX  -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=ON
make

test/cctest/cctest --list | tr -d '<' | xargs test/cctest/cctest

make install
