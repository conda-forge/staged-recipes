#!/bin/bash

pushd unix

./configure --prefix=$PREFIX
make
make install
