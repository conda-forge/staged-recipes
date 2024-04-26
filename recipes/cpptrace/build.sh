#!/bin/bash

cmake ${CMAKE_ARGS} -S . -B build -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=On -DCPPTRACE_GET_SYMBOLS_WITH_LIBDWARF=On -DCPPTRACE_USE_EXTERNAL_LIBDWARF=On -DCMAKE_PREFIX_PATH=$PREFIX
cmake --build build --config Release --target install
