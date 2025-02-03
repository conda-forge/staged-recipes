#!/bin/bash

set -x

mkdir build

cmake -S pythonfmu3/pythonfmu-export -B build -DPython3_EXECUTABLE:FILEPATH=$PYTHON -DCMAKE_BUILD_TYPE=Release
cmake --build build

$PYTHON -m pip install . -vv
