#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib

make
make install
