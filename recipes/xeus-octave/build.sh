#!/bin/bash

cmake -B build -D XEUS_OCTAVE_DISABLE_ARCH_NATIVE=ON ${CMAKE_ARGS}
cmake --build build --parallel ${CPU_COUNT}
cmake --install build --prefix ${PREFIX}
