#!/bin/bash

mkdir build
cd build
cmake ..
make
cp reaper ${PREFIX}/bin/