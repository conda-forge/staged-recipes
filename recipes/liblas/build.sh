#!/bin/bash

mkdir makefiles
cd makefiles
cmake -G "Unix Makefiles" ../
make && make install
