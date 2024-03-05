#!/bin/bash

# Like unzip -a
find . -type f \( -not -name "*.dll" -and -not -name "*.der" -and -not -name "*.p7s" -and -not -name "*.gpg" -and -not -name "*.orig" \) -print -exec sed -i 's/\r$//' {} \;

make shared
make stestlib
make PREFIX=$PREFIX install
