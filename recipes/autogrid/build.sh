#!/bin/bash

#tar -xvf autodocksuite-4.2.6-x86_64Linux2.tar

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
# export LDFLAGS="-Wl,-rpath,$PREFIX/lib $LDFLAGS"

mkdir -p $PREFIX/bin

meson setup $MESON_ARGS builddir

cd builddir

meson compile

cp autogrid4 $PREFIX/bin
