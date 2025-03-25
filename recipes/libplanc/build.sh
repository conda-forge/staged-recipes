#!/bin/bash

mkdir build && cd build
cmake -S ..
cmake --build .
cmake --install .
