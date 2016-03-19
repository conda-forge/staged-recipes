#!/bin/bash

pushd csa

./configure --prefix=$PREFIX
make
make tests
make install

popd
