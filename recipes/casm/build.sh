#!/bin/bash
./bootstrap.sh
./configure
make
make check 
make install 
