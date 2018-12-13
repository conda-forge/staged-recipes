#!/bin/bash

sh bootstrap.sh
./configure --prefix=$PREFIX
make
make install
make check
