#!/usr/bin/env bash

set -o errexit

cd build

cmake -DPYTHON_EXECUTABLE="$PYTHON"\
      -DMLIO_INCLUDE_CORE=FALSE\
      -DMLIO_INCLUDE_PYTHON_EXTENSION=TRUE\
      -DMLIO_INCLUDE_ARROW_INTEGRATION=TRUE ..

cmake --build . --target mlio-py-core
cmake --build . --target mlio-py-arrow

cd ../src/mlio-py

"$PYTHON" -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
