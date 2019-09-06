#!/bin/bash
./configure --prefix=${PREFIX}
make
make installcheck
make install
