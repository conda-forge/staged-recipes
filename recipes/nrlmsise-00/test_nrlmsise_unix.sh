#!/bin/bash

# Compile the test executable
$CC nrlmsise-00_test.c -I$PREFIX/include -L$PREFIX/lib -lnrlmsise-00 -o nrlmsise-00_test

# Check if the test executable was created
if [ ! -f nrlmsise-00_test ]; then
  echo "Test executable not found."
  exit 1
fi

# Execute the test using appropriate library paths
if [[ $(uname) == 'Darwin' ]]; then
  DYLD_LIBRARY_PATH=$PREFIX/lib ./nrlmsise-00_test
else
  LD_LIBRARY_PATH=$PREFIX/lib ./nrlmsise-00_test
fi
