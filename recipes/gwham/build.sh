#!/bin/bash

cd "wham_${PKG_VERSION}"
cd wham
make clean
make
PATH="$PATH:$PWD"
cd ../wham-2d
make clean
make
PATH="$PATH:$PWD"
cd ..
