#!/usr/bin/env bash

./configure -conda -nogui -verbose
./build -verbose
cp -r bin lib share $PREFIX
