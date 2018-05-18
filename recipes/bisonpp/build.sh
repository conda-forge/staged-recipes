#!/bin/bash

./configure --prefix=$PREFIX bison++-1.21
 
make
make install
