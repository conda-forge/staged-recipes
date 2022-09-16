#!/bin/sh

# Execute the Python test application using reaktplot
python test/example.py

# Build and execute the C++ test application using reaktplot
cd test/app
mkdir build
cd build
cmake -GNinja .. -DCMAKE_PREFIX_PATH=$PREFIX
ninja
# ./app

# Ignoring execution of app above because it is failing for strange reasons in macOS (but working fine in Linux).
# Error is:
# [1/2] Building CXX object CMakeFiles/app.dir/main.cpp.o
# [2/2] Linking CXX executable app
# libc++abi: terminating with uncaught exception of type pybind11::error_already_set: ModuleNotFoundError: No module named 'plotly'
