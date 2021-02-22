#!/bin/bash

./configure --prefix=$PREFIX --enable-qt5
make
make check
make install
