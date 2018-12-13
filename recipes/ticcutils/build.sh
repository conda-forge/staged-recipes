#!/bin/bash

sh bootstrap.sh
./configure --prefix=$PREFIX --with-boost=no
make
make install
make check
