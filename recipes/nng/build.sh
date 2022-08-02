#!/bin/bash
mkdir build
cd build
cmake -G Ninja ..
ninja
ninja test
ninja install
