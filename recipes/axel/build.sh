#!/bin/bash

./configure --disable-Werror --prefix=$PREFIX
make
make install
