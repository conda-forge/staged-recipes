#!/bin/bash

cmake -Bbuild ${CMAKE_ARGS} -D BUILD_TESTING=OFF -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=$PREFIX .
cmake --build build/ --target install
