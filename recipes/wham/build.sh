#!/bin/bash

cd "wham_${PKG_VERSION}"
cd wham
make clean
make
cd ../wham-2d
make clean
make
cd ..
