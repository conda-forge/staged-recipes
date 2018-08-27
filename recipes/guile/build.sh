#!/bin/bash

./configure --prefix="${PREFIX}"
make -j 2
make install
