#!/bin/bash

# The tests require libcpptest which isn't available yet
./configure  --prefix=$PREFIX  --disable-test 
make
make install
