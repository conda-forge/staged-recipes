#!/bin/bash

cmake -Bbuild ${CMAKE_ARGS} -D BUILD_UVW_SHARED_LIB=ON -D BUILD_TESTING=OFF -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=$PREFIX -D FIND_LIBUV=ON .
cmake --build build/ --parallel ${CPU_COUNT} --target install
