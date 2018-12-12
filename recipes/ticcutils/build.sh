#!/bin/bash

sh bootstrap.sh
./configure --prefix=$PREFIX
make
make install
