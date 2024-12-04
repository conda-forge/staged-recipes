#!/bin/bash

#tar -xvf autodocksuite-4.2.6-x86_64Linux2.tar

export PATH="$BUILD_PREFIX/bin:$PATH"


# Ensure csh is available
if ! command -v csh &> /dev/null; then
    echo "csh is not available. Creating a symlink to tcsh."
    ln -s "$(which tcsh)" "$BUILD_PREFIX/bin/csh"
fi

# Debugging: Verify csh is now available
if ! command -v csh &> /dev/null; then
    echo "Error: Failed to create csh symlink."
    exit 1
fi


# Add RPATH to link libraries during runtime
export LDFLAGS="-Wl,-rpath,$PREFIX/lib $LDFLAGS"

mkdir -p $PREFIX/bin


autoreconf -i

mkdir Linux

cd Linux
../configure
make

cp autogrid4 $PREFIX/bin
