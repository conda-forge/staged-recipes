#!/bin/bash

cmake -DCMAKE_BUILD_TYPE=Release     \
      ${CMAKE_ARGS} \
      $SRC_DIR

make install
