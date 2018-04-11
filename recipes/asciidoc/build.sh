#!/bin/bash

autoconf
./configure --prefix=$PREFIX
make
make install
