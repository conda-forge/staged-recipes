#!/bin/sh

# Execute the Python test application using reaktplot
python test/example.py

# Build and execute the C++ test application using reaktplot
cd test/app
mkdir build
cd build
cmake -GNinja .. -DCMAKE_PREFIX_PATH=$PREFIX
ninja
./app
