#!/bin/bash

mkdir -p $PREFIX/bin

# Conda package requires chopin2.py and functions.py scripts only
find . -type f \( -iname "chopin2.py" -o -iname "functions.py" \) -exec cp {} $PREFIX/bin \;
# Everything else can be removed
rm -rf *

# Make Python scripts executable
chmod +x $PREFIX/bin/chopin2.py $PREFIX/bin/functions.py
