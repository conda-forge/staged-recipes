#!/bin/bash

cd "${PKG_NAME}_${PKG_VERSION}"
cd wham
make clean
make
cd ../wham-2d
make clean
make
