#!/bin/bash

./configure --prefix=$PREFIX \
--disable-network \
--disable-static
make
make check
make install

