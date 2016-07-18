#!/bin/bash

./configure --prefix=$PREFIX
make
make -j 1 check && make install
