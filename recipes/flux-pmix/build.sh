#!/bin/bash
cmake ${CMAKE_ARGS} .

make V=1

export FLUX_TESTS_LOGFILE=t
make check
make install
