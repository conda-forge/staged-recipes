#!/bin/bash

[[ -d build ]] || mkdir build
cd build/

qmake ../qtlocation.pro

# Log files on Travis CI are limited to 4MB and this step usually exceeds
# that limit. Removes ability to diagnose, but lets the build complete.
if [ $(uname) == Darwin ]; then
    echo "Silencing make step while running on Travis-CI"
    make -j$CPU_COUNT > /dev/null
    make check > /dev/null
    make install
else
    make -j$CPU_COUNT
    make check
    make install
fi

# Try building "examples/" as a test
echo "Building examples to test library install"
mkdir -p examples
cd examples/

qmake ../../examples/examples.pro

if [ $(uname) == Darwin ]; then
    echo "Silencing make step while running on Travis-CI"
    make -j$CPU_COUNT > /dev/null
    make check > /dev/null
else
    make -j$CPU_COUNT
    make check
fi
