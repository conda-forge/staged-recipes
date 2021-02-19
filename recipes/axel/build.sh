#!/bin/bash

./configure --disable-Werror --prefix=$PREFIX
make
make check
make install
make installcheck
