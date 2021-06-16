#!/bin/bash

ln -sf $(pwd)/data/screenshots $(pwd)/docs/images/ &&
mkdir -p build &&
cd build && \
cmake .. -GNinja && \
ninja && \
cd ..

${PYTHON} utils/generate_cython.py && \
cd bindings/cython && \
${PYTHON} setup.py build_ext -i && \
${PYTHON} setup.py develop --user && \
cd ../..