#!/bin/bash
cd src
make -j${NUM_CPUS} all
make install
