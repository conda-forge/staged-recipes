#!/bin/bash

chmod +x configure
./configure  --prefix=$PREFIX
make
make install
