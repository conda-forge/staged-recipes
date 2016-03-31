#!/bin/bash

./configure --prefix=$PREFIX --exec-prefix=$PREFIX
make
make bindir=. installcheck
make install
