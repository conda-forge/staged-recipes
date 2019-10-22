#!/bin/bash

cd libLAS-1.8.1/
mkdir makefiles
cd makefiles
cmake -G "Unix Makefiles" ../
make && make install
