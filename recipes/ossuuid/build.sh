#!/bin/bash

./configure  --prefix=$PREFIX
make -j
make install
make check
