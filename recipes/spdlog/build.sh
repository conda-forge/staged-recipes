#!/bin/bash

cmake . -DCMAKE_INSTALL_PREFIX=$PREFIX
make
make test
make install
