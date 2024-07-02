#!/bin/bash

cmake ${CMAKE_ARGS} $SRC_DIR -B build -DCMAKE_CXX_STANDARD=17
cmake --build build --target install
