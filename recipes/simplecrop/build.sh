#! /bin/bash

mkdir src/_build
cd src/_build

cmake ../ -DCMAKE_INSTALL_PREFIX=$PREFIX
make all install
