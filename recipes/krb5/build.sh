#!/bin/bash

cd src

./configure --prefix=$PREFIX
make
make install
