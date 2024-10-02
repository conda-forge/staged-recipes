#!/bin/bash

mkdir build
cd build

cmake \
  -LAH \
  ${CMAKE_ARGS} \
  ..

cmake build

cmake install
