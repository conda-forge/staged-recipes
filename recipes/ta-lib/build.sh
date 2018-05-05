#!/bin/bash
printenv
./configure --prefix=$PREFIX
make
make install