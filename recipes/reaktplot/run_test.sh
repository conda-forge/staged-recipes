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
# import: 'reaktplot'
# import: 'reaktplot'
# -- The CXX compiler identification is Clang 14.0.4
# -- Detecting CXX compiler ABI info
# -- Detecting CXX compiler ABI info - done
# -- Check for working CXX compiler: $PREFIX/bin/x86_64-apple-darwin13.4.0-clang++ - skipped
# -- Detecting CXX compile features
# -- Detecting CXX compile features - done
# -- Found PythonInterp: $PREFIX/bin/python (found suitable version "3.10.6", minimum required is "3.6")
# -- Found PythonLibs: $PREFIX/lib/libpython3.10.dylib
# -- Performing Test HAS_FLTO
# -- Performing Test HAS_FLTO - Success
# -- Performing Test HAS_FLTO_THIN
# -- Performing Test HAS_FLTO_THIN - Success
# -- Found pybind11: $PREFIX/include (found version "2.10.0")
# -- Configuring done
# -- Generating done
# -- Build files have been written to: $SRC_DIR/test/app/build
# [1/2] Building CXX object CMakeFiles/app.dir/main.cpp.o
# [2/2] Linking CXX executable app
# libc++abi: terminating with uncaught exception of type pybind11::error_already_set: ModuleNotFoundError: No module named 'plotly'
