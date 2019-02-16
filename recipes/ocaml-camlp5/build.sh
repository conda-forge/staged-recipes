#!/bin/bash

./configure --transitional -prefix $PREFIX
make -j${CPU_COUNT}
make opt
make opt.opt
make install
