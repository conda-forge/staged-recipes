#!/usr/bin/env bash

mkdir _build
cd _build
cmake ../dxtbx "-DCMAKE_INSTALL_PREFIX=$PREFIX"
make
make install
pip install ../dxtbx