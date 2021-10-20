#!/usr/bin/env bash

ARCH=native ./configure -conda -nogui -verbose
./build -verbose
cp -r bin lib share $PREFIX
