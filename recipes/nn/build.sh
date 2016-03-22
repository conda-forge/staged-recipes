#!/bin/bash

pushd nn

./configure --prefix=$PREFIX
make
make tests
make install

popd
