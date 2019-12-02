#!/bin/bash

set -ex

export PATH=/usr/local/cuda-8.0/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64\
         ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

$PYTHON -m pip install . --no-deps -vv
