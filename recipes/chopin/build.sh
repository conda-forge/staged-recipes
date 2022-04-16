#!/bin/bash

mkdir -p $PREFIX/bin

# Conda package requires chopin.py and functions.py scripts only
find . -type f \( -iname "chopin.py" -o -iname "functions.py" \) -exec cp {} $PREFIX/bin \;
# Everything else can be removed
rm -rf *

# Make Python scripts executable
chmod +x $PREFIX/bin/chopin.py $PREFIX/bin/functions.py
