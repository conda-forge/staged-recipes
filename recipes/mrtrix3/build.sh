#!/usr/bin/env bash

export EIGEN_CFLAGS=$(pkg-config --cflags eigen3)

./configure -nogui -noshared -openmp
./build -verbose
