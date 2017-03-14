#!/bin/bash

./configure --prefix=${PREFIX} --enable-sse
make
make install
