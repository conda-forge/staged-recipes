#!/bin/bash

cmake ${CMAKE_ARGS}  $SRC_DIR  -B build 
cmake --build build --target install
