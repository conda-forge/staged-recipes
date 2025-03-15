#!/bin/bash

# Create bin directory if it doesn't exist
mkdir -p $PREFIX/bin

# Copy each binary to bin directory and make executable
cd $SRC_DIR
cp psovina1 $PREFIX/bin/psovina1
cp psovina1.1 $PREFIX/bin/psovina1.1
cp psovina2 $PREFIX/bin/psovina2

# Make all binaries executable
chmod +x $PREFIX/bin/psovina1
chmod +x $PREFIX/bin/psovina1.1
chmod +x $PREFIX/bin/psovina2