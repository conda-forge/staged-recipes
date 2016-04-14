#!/bin/bash

./configure --prefix=$PREFIX
make
make tests
make install
