#!/bin/bash
./configure --prefix=$PREFIX
make check
make install
make fasttest


