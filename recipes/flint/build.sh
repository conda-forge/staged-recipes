#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"

chmod +x configure

./configure --prefix=$PREFIX

make
make check
make install

